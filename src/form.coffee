utils = require './utils'
core = require './core'
model = require './model'
view = require './view'

Form = view.View
    methods:
        edit: (model)->
            @set_val model
        val: (args...)-> 
            if args.length == 0
                @get_val()
            else
                @set_val args...
        get_val: ->
            throw "NotImplemented"
        set_val: (data)->
            throw "NotImplemented"
        is_modified: ->
            throw "NotImplemented"
        validate: ->
            throw "NotImplemented"
        print_errors: (errors)->
            throw "NotImplemented"

PotatoView = Form
    el: "<fieldset>"
    methods:
        get_val: ->
            utils.mapDict ((c)->c.val()), @components()
        set_val: (val)->
            for k,v of @components()
                if val[k]?
                    this[k].set_val val[k]
        validate: ->
            """
            Validate the form and print out eventual
            errors in the form.
            Returns
              - undefined if the value is not valid.
              - the value of the model else.
            """
            value = @val()
            validation = @model.validate value
            if validation.ok
                value
            else
                @printErrors validation.errors
                undefined
        print_errors: (errors)->


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
            template += """
                <label>#{label}</label>
                <##{k}/>
                <div style='clear: both;'/>
            """
        else
            template += "<##{k}/>"
    content.template = template
    PotatoView content

InputForm = Form
    el: "<input type=text>"
    methods:
        get_val: ->
            @el.val()
        set_val: (val)->
            @el.val val
            
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
        set_val: (val)->
            @el.val ""+val

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
        list:    (model)-> JSONForm    model: model
        json:    (model)-> JSONForm    model: model
        string:  (model)-> InputForm   model: model
        integer: (model)-> IntegerForm model: model
        choice:  (model)-> JSONForm    model: model
        potato: PotatoViewOf
    FormOf: (model)->
        @widgets[model.type](model)

module.exports =
    FormFactory: FormFactory
    Form: Form
    JSONForm: JSONForm
