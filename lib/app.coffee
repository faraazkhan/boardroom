express = require 'express'
Sockets = require './services/sockets'
configure = require './config'
addRouting = require './routes'

class BoardroomApp
  constructor: (@opts = {}) ->
    @opts.cluster ?= false

    @app = express()
    configure @app
    addRouting @app

  start: ->
    server = @app.listen parseInt(process.env.PORT) || 7777
    Sockets.start server, @opts

module.exports = BoardroomApp
