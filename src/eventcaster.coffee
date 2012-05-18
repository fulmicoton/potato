utils = require './utils'
core = require './core'

EventCaster = core.Potato
    
    properties:
        __listeners: core.Literal
            default: -> {}
    
    static:
        __init__: (obj)->
            obj.trigger "init"

    methods:
        trigger: (evtName, args...)->
            listeners = @__listeners[evtName]
            if listeners?
                listeners = listeners.slice 0
                for callback in listeners
                    callback args...
        
        bind: (evtName, callback)->
            @__listeners[evtName] = @__listeners[evtName] ? []
            @__listeners[evtName].push callback

        unbind: (evtName, callback)->
            callbacks = @__listeners[evtName]
            if callbacks?
                utils.removeEl callbacks, callback, -1
                if callbacks.length == 0
                    delete @__listeners[evtName]
            this

module.exports =
    EventCaster: EventCaster
