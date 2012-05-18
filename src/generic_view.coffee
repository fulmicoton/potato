core = require './core'
model = require './model'
view = require './view'


PotatoViewOf = (model)->
    components = {}
    template = ""
    for cid, component of model.components()
        components[cid] = ViewFactory.ViewOf(component)
        template += "<" + cid + "/>"
    potatoView = view.View
        template: template
        components: components
    potatoView.setModel model
    potatoView

JSONView = Form
    template: "{{ model.toJSON }}"

ViewFactory = core.Tuber
    __sectionHandlers__: {}
    widgets:
        list:    (model)-> JSONView    {model: model}
        json:    (model)-> JSONView    {model: model}
        string:  (model)-> JSONView    {model: model}
        integer: (model)-> JSONView    {model: model}
        choice:  (model)-> JSONView    {model: model}
        potato: PotatoViewOf
        #collection: CollectionFormOf
    ViewOf: (model)->
        @widgets[model.type](model)

module.exports =
    FormFactory: FormFactory
    Form: Form
    JSONForm: JSONForm
