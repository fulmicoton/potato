core = require './core'
model = require './model'
view = require './view'

MenuItem = model.Model
	components:
		id: model.String
		label: model.String

TabMenu = view.View
	help: """
		This menu represents a tabmenu. That is a menu
		with always exactly one item selected at a time.

		If a selected value is supplied by the user,
		the event is triggered once on startup.

		If a user clicks more than once on a menu item,
		the event is only triggered the first time.
		"""

	el: "<ul class='menu'>"
	
	model: core.ListOf MenuItem
		selected: model.String

	template: """
		{{#model}}<li data-item_id='{{id}}'>{{label}}</li>{{/model}}
		"""

	methods:
		findItem: (item_id)->
			@find "li[data-item_id='#{item_id}']"

		select: (item_id)->
			if @selected != item_id
				@findItem(@selected).removeClass "selected"
				@findItem(item_id).addClass "selected"
				@selected = item_id
				@trigger "select", item_id
		
		onRender: ->
			# we select at least one element on render.
			if @findItem(@selected).length != 1
				if @model.length > 0
					@selected = @model[0].item
			selected = @selected
			@selected = undefined
			@select selected
	
	events:
		"li" : "click" : (evt)->
			item_id = evt.target.dataset.item_id
			@select item_id

TemplateView = view.View
	__sectionHandlers__:
	        context: (v)->
	        	__extract_context__: v

TemplateView = TemplateView
	context: (parent)-> parent
	methods:
		render: (parent)->
			context = @__potato__.__extract_context__.apply parent
			@el.html @__potato__.__template__ context

module.exports = 
	TabMenu: TabMenu
	TemplateView: TemplateView
