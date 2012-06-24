utils = require './utils'

rextend = utils.rextend
pick = utils.pick
extend = utils.extend

# **Tuber** is the root of potatoe inheritance.
# 
# Potatoe inheritance uses an unusual syntax.
# A Potatoe itself is the function allowing to extend
# itself.
#
# Instead of going :
#
#     class Animal
#         # Definition of the content of the 
#         # Animal class.
#           
#     class Dog extends Animal
#         # Definition of the content of the 
#         # Dog class. Dogs inherits from
#         # Animal
# 
# With Potatoe, you would write:
# 
#     Animal = Potatoe
#         # Definition of the content of the 
#         # Animal class.
#
#     Dog = Animal
#         # Definition of the content of the 
#         # Dog class. Dogs inherits from
#         # Animal
#
# While the purpose of such a syntax may 
# not make sense at the moment,
# we will see that this syntax makes it possible to
# define anonymous classes, which is precious when
# programming while relying heavily on composition
# and deep overriding.
#
# Tuber also makes it possible for someone 
# to define static members for your class.
#



interfaceToContent = (interfas, sectionHandlers)->
    extraContent = {}
    for k,v of interfas
        sectionHandler = sectionHandlers[k]
        if sectionHandler?
            rextend extraContent, sectionHandler v
        else
            extraContent[k] = v
    extraContent

Tuber = (content)->
    extendMyself = (extraInterface)->
        extraContent = interfaceToContent  extraInterface, content.__sectionHandlers__
        # For each method, automatically add pythonic
        # methods to the class.
        if @constructor.THIS_IS_NOT_A_CONSTRUCTOR_DUMMY?
            msg = "Do no call 'new YourPotato()'. Instanciation is done via Yourmake()'."
            throw msg    
        newContent = rextend {}, content, extraContent
        Tuber newContent
    extendMyself.THIS_IS_NOT_A_CONSTRUCTOR_DUMMY = true
    rextend extendMyself, content
    extendMyself


# ---------------------------
# **Potato** is the real deal.
# 
# You may have notice that Tubers cannot be instanciated.
# The inheritance syntax conflicts with the usual
# instanciation syntax. We are not able to do 
#
#     dog = new Dog()
#
# Instanciation will be done via a "make" static
# method. Which basically delegates to its components.
#

delegateTo = (delegateMember, methodName)->
    ->
        member = (delegateMember.apply this)
        member[methodName].apply member, arguments

Potato = Tuber
    __sectionHandlers__:
        
        static: (staticDic)->
            staticDic
        
        properties: (propertyDic)->
            __potaproperties__ : propertyDic
        
        methods: (methodDic)->
            res = { __potaproto__ : methodDic }
            for k,v of methodDic
                do (k,v) ->
                    if not res[k]?
                        res[k] = (self,args...)->
                            self[k](args...)
            res
        
        components: (componentDic)->
            __potacompo__ : componentDic

        delegates: (delegateDic)->
            delegated_methods = {}
            for k,v of delegateDic
                do (k,v)->
                    delegated_methods[k] = (args...)->
                        this[v][k] args...
            __potaproto__: delegated_methods

Potato = Potato

    methods:
        components: ->
            @__potato__.components this
        
        set: (data)->
            if data.__potato__?
                data
            else
                components = @components()
                for componentId, component of components
                    if data[componentId]?
                        this[componentId] = component.set this[componentId], data[componentId]
                this
        
        setData: (data)->
            components = @components()
            for componentId, component of components
                if data[componentId]?
                    this[componentId] = component.setData this[componentId], data[componentId]
            this
        
        copy: (obj)->
            @__potato__.make obj
    
    static:
        type: 'potato'
        __init__: (obj)->
        # Produce an instance with 
        # the data "data"
        make: (data=undefined)->
            potato = this
            actualConstructor = ()->
                for k,v of potato.__potacompo__
                    this[k] = v.make()
                for k,v of potato.__potaproperties__
                    this[k] = v.make()
                this
            actualConstructor::__potato__ = potato
            extend actualConstructor.prototype, potato.__potaproto__
            newInstance = new actualConstructor
            @__init__ newInstance
            if data?
                newInstance.set data
            newInstance
        makeFromData: (data)->
            obj = @make()
            obj.setData data
            obj
        components: ->
            @__potacompo__ 


error = (args...)->
    for arg in args
        console.log "ERROR : ", arg


# ---------------------------
# You need some kind of Leaf to this tree of composed models.
# That's the role of Literal. 
# 
# Literal may not contain any methods. They 
# are actual javascript litterals, which 
# allows you to get/set those via simple
# 
# Serialization, etc. can be done via the static
# method of their Tuber.
#
#     dog.age = 12
#
#
Literal = Tuber
    __sectionHandlers__: {}
    type: 'json'
    make: (val)->
        if val?
            val
        else
            pick  @default
    toJSON: (val)->
        JSON.stringify @toData val
    toData: (val)->
        val
    set: (obj,val)->
        val
    setData: (obj,val)->
        val
    makeFromData: (data)->
        data

# ----------------------------------
# List are also handled by Potato
#
List = Literal
    type: 'list'
    itemType: Literal
        # basically the type of the object.
        default: Literal
    
    toData: (obj)->
        @__potato__.itemType.toData it for it in obj
    
    add: (obj,item)->
        obj.push item

    addData: (obj,data)->
        item = @itemType.make data
        @add obj,item
    
    make: (data=[])->
        for k in [0...data.length]
            data[k] = @itemType.make data[k]
        data
    
    set: (l,data)->
        data
    
    setData: (obj,val)->
        obj.length = 0
        for it in val
            @add obj, @itemType.make it
        obj
    
    makeFromData: (data)->
        obj = @make()
        obj.setData data
        obj

# ----------------------------------
# ... as well as maps
#

Map = Literal
    type: 'map'
    make: (data)->
        newInstance = {}
        if data?
            newInstance.set data
        newInstance
    
    itemType: Literal
    
    toData: (obj)->
        data = {}
        for k,v of obj
            data[k] = @__potato__.itemType.toData v
        data
    
    set: (obj,data)->
        data

    setData: (obj,val)->
        for k,v of obj
            delete obj[k]
        for k,v of val
            obj[k] = @itemType.makeFromData val
    
    makeFromData: (data)->
        obj = @make()
        obj.setData data
        obj
#
# Just a small helper to create map and lists.
#

ListOf = (itemType)->
    List itemType: itemType

MapOf = (itemType)->
    Map itemType: itemType

notImplementedError = ->
    throw "Not Implemented Error"


HardCoded = (value)->
    make: -> pick value

module.exports =
    ListOf: ListOf
    MapOf: MapOf
    notImplementedError: notImplementedError
    Literal: Literal
    HardCoded: HardCoded
    Potato: Potato
    Tuber: Tuber
