core = require './core'
model = require './model'
eventcaster = require './eventcaster'
utils = require './utils'
hogan = require 'hogan.js'

TEMPLATE_PLACEHOLDER_PTN = /<#\s*([\w_]+)\s*\/?>/

if not window?
    $ = ((x)->x)
else
    $ = window.$

HTMLElement = core.Literal
    tagName: '<div>'
    make: (elval)->
        $(elval ? @tagName)
    set: (self,obj)->
        obj

POTATO_SELECTOR_DSL_SEP = /$|\ /

View = eventcaster.EventCaster
    __sectionHandlers__:
        template: (tmpl)->
            while placeholderMatch = TEMPLATE_PLACEHOLDER_PTN.exec tmpl
                [ whole, cid ] = placeholderMatch
                index = placeholderMatch.index
                index2 = index + whole.length
                newEl = "<div id='__ELEMENT_#{cid}'></div>"
                tmpTmpl = tmpl[0...index] + newEl + tmpl[index2...]
                tmpl = tmpTmpl
            __template__: (args...)->hogan.compile(tmpl).render(args...)
        events: (v)->
            __events__: v
        model: (v)->
            __potaproperties__ : model : v
        el: (v)->
            __potaproperties__ :
                el: HTMLElement
                    tagName: v

View = View
    template: ''
    model: model.Model
    el: "<div>"
    properties:
        __bound__: core.ListOf(core.Potato)
    methods:
        context: (parent)->
            if parent?
                parent
            else
                this
        
        destroy: ->
            @unbindEvents()
            @el.remove()
            @trigger "destroy"

        setModel: (model)->
            @model = model
            for cid, component of @components()
                if component.__isView__?
                    if model[cid]?
                        @[cid].setModel model[cid]
            this
        
        autoRefresh: ->
            @model.bind "change", =>
                @render()

        renderTemplate: (context)->
            @el.html @__potato__.__template__ context
            for componentId, component of @components()
                if component.__isView__?
                    componentContainer = @el.find "#__ELEMENT_#{componentId}"
                    if componentContainer.size()==1
                        this[componentId].render context
                        componentContainer.replaceWith this[componentId].el

        find: (elDsl)->
            elDsl = elDsl.trim()
            if elDsl==""
                return this
            else if elDsl[0] == "@"
                sep = POTATO_SELECTOR_DSL_SEP.exec(elDsl).index
                head = elDsl[1...sep]
                elDsl = elDsl[sep+1...]
                window.el = this[head]
                # little hack to handle the @el case.
                # jquery's find "" does not returns this.
                if elDsl.trim() == ""
                    this[head]
                else
                    this[head].find elDsl
            else
                @el.find elDsl
        
        unbindEvents: ->
            for [el, evt, handler] in @__bound__
                el.unbind evt, handler
            this
        
        bindEvents: ->
            @unbindEvents()
            me = this
            for elDsl, bindEvents of @__potato__.__events__
                el = @find elDsl
                for evt, callback of bindEvents
                    do (callback)->
                        handler = (args...)->callback.call(me,args...)
                        el.bind evt, handler
                        me.__bound__.push [el, evt, handler]
            this

        render: (parent)->
            context = @context parent   
            @renderTemplate context
            @bindEvents()
            @trigger "render"

    static:
        keyHandlers:
            el: (content, tagValue)->
                content.components.el = HTMLElement
                    tagName: tagValue

        loadInto: ($container) ->
            instance = @make()
            instance.el = $ $container
            instance.render()
            instance

        __isView__: true

CollectionViewOf = (itemType) ->
    View
        el: '<ul>'
        components:
            __items: core.ListOf(itemType)
        methods:
            addData: (data)->
                newItem = @__addViewItem data
                newItem.render()
                @el.append newItem.el
                this

            remove: (item)->
                nbRemovedEl = utils.removeEl @__items, item, 1
            
            setModel: (itemModelList)->
                @model = itemModelList
                @__buildItemsFromModel()
            
            __addViewItem: (model)->
                newItem = itemType.make()
                newItem.setModel model
                @__items.push newItem
                newItem.bind "destroy", =>
                    @remove newItem
                newItem
            
            destroyAllItems: ->
                for item in @__items
                    if item.destroy?
                        item.destroy()
                @__items = []

            __buildItemsFromModel: ->
                @destroyAllItems()
                for item in @model
                    @__addViewItem item
                this
            
            __renderItems: ->
                @el.empty()
                for it in @__items
                    it.render()
                    @el.append it.el
            
            render: ->
                @__renderItems()
                @trigger "render"


module.exports =
    View: View
    HTMLElement: HTMLElement
    CollectionViewOf: CollectionViewOf
