http = require 'http'

speclib = "#{__dirname}/.."
models = require "#{speclib}/support/model_test_support"
request = require 'supertest'
superagent = require 'superagent'
jsdom = require 'jsdom'
url = require 'url'
$ = require 'jquery'
async = require 'async'

loginProtection = require '../../../lib/services/authentication/login_protection'
Factory = require './factories'

Boardroom = require "../../../lib/boardroom"

port = 6969

class Session

  constructor: ->
    @boardroom = new Boardroom { loginProtection: @wrappedLoginProtection, @createSocketNamespace }

  reset: =>
    @end()
    @server = http.createServer(@boardroom.app).listen(port++)

  login: (user) =>
    @user = user

  logout: => @user = undefined

  wrappedLoginProtection: (request, response, next) =>
    request.session ?= {}
    request.user = @user if @user?
    loginProtection(request,response, next)

  createSocketNamespace: (request, response, next) => next()

  request: =>
    request(@server)

  end: =>
    @logout()
    @server?.close()
    @server = undefined

describeController = (controller, cb) ->
  session = new Session

  beforeEach -> session.reset()

  describe controller, -> cb?(session)

  afterEach -> session?.end()

exports = { request, superagent, jsdom, url, $, async, describeController, Factory }
exports[key] = value for key, value of models

module.exports = exports
