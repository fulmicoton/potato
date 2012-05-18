core = require './core'
utils = require './utils'
eventcaster = require './eventcaster'
model = require './model'
view = require './view'
form = require './form'
widget = require './widget'

module.exports = utils.extend {}, core,  utils, eventcaster, model, view, form, widget
