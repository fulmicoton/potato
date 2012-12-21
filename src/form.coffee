utils = require './utils'
core = require './core'
model = require './model'
view = require './view'
widget = require './widget'

Form = view.View
    methods:
        edit: (model)->
            @set_val model
        val: (value)-> 
            if not value?
                @get_val()
            else
                @set_val value
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
            res = {}
            for k,v of @components()
                res[k] = this[k].get_val()
            return res

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
            validation = @__potato__.model.validate value
            if validation.ok
                @print_valid()
                value
            else
                @print_errors validation.errors
                undefined
        print_errors: (errors)->
            for k,v of @components()
                if errors[k]?
                    this[k].print_errors errors[k]
                else
                    this[k].print_valid()

        print_valid: ->
            for k,v of @components()
                this[k].print_valid()

PotatoViewOf = (model)->
    content = {}
    content.components = utils.mapDict ((model)->FormFactory.FormOf model), model.components()
    utils.rextend content, static: model: model
    template =''
    if model.label
        template += "<legend>#{model.label}</legend>"
    for k,v of model.components()
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

Input = view.View
    el: "<input type=text>"
    methods:
        get_val: ->
            @el.val()
        set_val: (val)->
            @el.val val
        val: (value)->
            if not value?
                @get_val()
            else
                @set_val value

Field = Form
    template: "<#input/><#error/>"
    components:
        input: Input
        error: widget.TemplateView
            el: "<div class='error_msg'>"
            template: "{{errors}}"
    delegates:
        get_val: "input"
        set_val: "input"
    methods:
        print_errors: (errors)->
            @error.render errors: errors
        print_valid: ->
            @error.render errors: ""

TextField = Field


Checkbox = Field
    components: 
        input : Input
            el: "<input type='checkbox'>"
            methods:
                get_val: ->
                    @el.attr("checked") == "checked"
                set_val: (val)->
                    @el.attr "checked", val

IntegerForm = Field
    components: 
        input : Input
            el: "<input type='number' step='1' required='' placeholder=''>"
            methods:
                onRender: ->
                    integerModel = @components().model
                    @el.attr "min", integerModel.MIN
                    @el.attr "max", integerModel.MAX
                    @el.attr "step", integerModel.STEP
                    @el.attr "placeholder", integerModel.help ? integerModel.label ? ""
                get_val: ->
                    parseInt (@el.val()),10
                set_val: (val)->
                    @el.val ""+val

JSONForm = Field
    components:
        input: Input
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
        "boolean": (model)-> Checkbox static: model: model
        list:    (model)-> JSONForm    static: model: model
        json:    (model)-> JSONForm    static: model: model
        string:  (model)-> TextField   static: model: model
        integer: (model)-> IntegerForm static: model: model
        choice:  (model)-> JSONForm    static: model: model
        potato: PotatoViewOf
    FormOf: (model)->
        @widgets[model.type](model)

module.exports =
    FormFactory: FormFactory
    Form: Form
    JSONForm: JSONForm
