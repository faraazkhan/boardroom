http = require 'http'

speclib = "#{__dirname}/.."
models = require "#{speclib}/support/model_test_support"
request = require 'supertest'
superagent = require 'superagent'
jsdom = require 'jsdom'
url = require 'url'
$ = require 'jquery'
async = require 'async'
authenticate = require '../../../lib/services/authenticate'

Boardroom = require "../../../lib/boardroom"

port = 6969

class Session

  constructor: ->
    @boardroom = new Boardroom { authenticate: @wrappedAuthenticate, @createSocketNamespace }

  reset: =>
    @end()
    @server = http.createServer(@boardroom.app).listen(port++)

  login: (@user = 'user') =>

  logout: => @user = undefined

  wrappedAuthenticate: (request, response, next) =>
    request.session ?= {}
    request.session.user_id = if @user? then @user
    authenticate(request,response, next)

  createSocketNamespace: (request, response, next) => next()

  request: =>
    request(@boardroom.app)

  end: =>
    @logout()
    @server?.close()
    @server = undefined


describeController = (controller, cb) ->
  session = new Session

  beforeEach -> session.reset()

  describe controller, -> cb?(session)

  afterEach -> session?.end()

exports = { request, superagent, jsdom, url, $, async, describeController }
exports[key] = value for key, value of models

module.exports = exports
