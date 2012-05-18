core = require './core'
eventcaster = require './eventcaster'
utils = require './utils'

Integer = core.Literal
    type: 'integer'
    MIN: 0
    MAX: 10
    STEP: 1
    default: 0
    isValid: (data)->
        (typeof data) == "number" and (data == Math.round data)

String = core.Literal
    type: 'string'
    default: ""
    isValid: (data)->
        (typeof data) == "string"

NonEmptyString = String
    default: "something..."
    isValid: (data)->
        (String.isValid data) and (data != "")

Boolean = core.Literal
    type: 'boolean'
    default: false
    isValid: (data)->
        (typeof data) == "boolean"

Model = eventcaster.EventCaster
    
    methods:
        destroy: ->
            @trigger "delete"

        # Returns JSON String describing the state.
        toJSON: ->
            JSON.stringify @toData()
        
        # Returns JSON Object describing the state
        toData: ->
            data = {}
            for k,v of @components()
                data[k] = v.toData @[k]
            data
        
        copy: (obj)->
            @__potato__.make obj
        
        
        set: (data)->
            if data.__potato__?
                data
            else
                components = @components()
                for componentId, component of components
                    if data[componentId]?
                        this[componentId] = component.set this[componentId], data[componentId]
            @trigger "change"
            this

        find: (elDsl)->
            elDsl = elDsl.trim()
            if elDsl==""
                return this
            if elDsl[0] == "@"
                sep = POTATO_SELECTOR_DSL_SEP.exec(elDsl).index
                head = elDsl[1...sep]
                elDsl = elDsl[sep+1...]
                target = this[head]
                target.find elDsl[1..]
            else
                console.log "Selection DSL for model should start with an @"
                return null
        url: ->
        
    static:
        isValid: (obj)->
            for cid, comp of @components()
                if comp.isValid? and not comp.isValid obj[cid]
                    return false
            true
                    
        # Returns an object from this JSON data.        
        fromJSON: (json)->
            data = JSON.parse json
            @fromData data
        
        fromData: (data)->
            obj = @make()
            @setData obj, data

CollectionOf = (itemType) ->
    
    Model
        components:
            __items: core.ListOf(itemType)
        
        methods:
            add: (item)->
                @__items.push item
                @trigger "add", item
                @trigger "change"
                item.bind "change", => @trigger "change"
                item.bind "delete", => @remove item
                this
            
            remove: (item)->
                nbRemovedEl = utils.removeEl @__items, item, 1
                if nbRemovedEl>0
                    @trigger "change"
            
            filter: (predicate)->
                els = []
                for el in @items()
                    if predicate(el)
                        els.push el
                els
            
            items: ->
                @__items
            
            setData: (data)->
                @__items = []
                for itemData in data
                    @addData itemData
                @trigger "change"
                this

            toData: ->
                @__potato__.__content___.components.items.toData this
            
            addData: (itemData)->
                @add itemType.fromData itemData
                
        static:
            setData: (obj,data)->
                obj.__items = []
                for itemData in data
                    obj.addData itemData
                obj
###
TODO Add a view model.

ViewModel = potato.Model
    __sectionHandlers__: 
        model: (val)->
            properties:
                model: model
###

model =
    Model: Model
    CollectionOf: CollectionOf
    Integer: Integer
    String: String
    Boolean: Boolean
    NonEmptyString: NonEmptyString
#    ViewModel: ViewModel

module.exports = model
