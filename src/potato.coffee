core = require './core'
utils = require './utils'
eventcaster = require './eventcaster'
model = require './model'
view = require './view'
form = require './form'
widget = require './widget'
model_extras = require './model-extras'

module.exports = utils.extend {}, core,  utils, eventcaster, model, view, form, widget, model_extras
