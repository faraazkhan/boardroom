express = require 'express'

Sockets = require './services/sockets'

configure = require './config'
addRouting = require './routes'

class Boardroom
  constructor: (@opts = {}) ->
    @env = @opts.env ? 'development'
    @port = @opts.port ? 7777
    loginProtection = @opts.loginProtection ? require './services/authentication/login_protection'
    createSocketNamespace = @opts.createSocketNamespace ? Sockets.middleware

    @app = express()
    configure @app
    addRouting @app, loginProtection, createSocketNamespace

  start: ->
    server = @app.listen @port
    Sockets.start server

module.exports = Boardroom
