utils = require './utils'
core = require './core'
model = require './model'
view = require './view'

Form = view.View
    methods:
        edit: (model)->
            set_val model
            @model = model
        val: (args...)-> 
            if args.length == 0
                @get_val()
            else
                @set_val args...
        get_val: ->
            undefined
        set_val: (data)->
        is_modified: ->
            false

PotatoView = Form
    el: "<fieldset>"
    methods:
        get_val: ->
            res = {}
            for k,v of @model.components()
                res[k] = @[k].get_val()
            res

PotatoViewOf = (model)->
    content = {}
    content.components = utils.mapDict ((model)->FormFactory.FormOf model), model.components()
    content.model = model
    template =''
    if model.label
        template += "<legend>#{model.label}</legend>"
    for k,v of content.model.components()
        if v.type != 'potato'
            label = v.label ? k
            template += "<label>#{label}</label>"
            template += "<##{k}/>"
            template += "<div style='clear: both;'/>"
        else
            template += "<##{k}/>"
    content.template = template
    PotatoView content

InputForm = Form
    el: "<input type=text>"
    methods:
        get_val: ->
            @el.val()
            
IntegerForm = Form
    el: "<input type='number' step='1' required='' placeholder=''>"
    methods:
        onRender: ->
            integerModel = @components().model
            @el.attr "min", integerModel.MIN
            @el.attr "max", integerModel.MAX
            @el.attr "step", integerModel.STEP
            @el.attr "placeholder", integerModel.help ? integerModel.label ? ""
        get_val: ->
            parseInt @el.val(),10

JSONForm = Form
    template: "{}"
    el: "<textarea>"
    methods:
        get_val: ->
            JSON.parse @el.val()
        set_val: (val)->
            @el.val JSON.stringify val

FormFactory = core.Tuber
    __sectionHandlers__: {}
    widgets:
        list:    (model)-> JSONForm    {components: {model: model} }
        json:    (model)-> JSONForm    {components: {model: model} }
        string:  (model)-> InputForm   {components: {model: model} }
        integer: (model)-> IntegerForm {components: {model: model} }
        choice:  (model)-> JSONForm    {components: {model: model} }
        potato: PotatoViewOf
    FormOf: (model)->
        @widgets[model.type](model)

module.exports =
    FormFactory: FormFactory
    Form: Form
    JSONForm: JSONForm
