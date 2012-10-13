speclib = "#{__dirname}/.."
require "#{speclib}/support/spec_helper"
models = require "#{speclib}/support/model_test_support"
request = require 'supertest'
jsdom = require 'jsdom'
url = require 'url'
$ = require 'jquery'

{ LoggedOutRouter, LoggedInRouter, routers } = require "#{speclib}/support/authentication"

models.finalizers.push ->
  router.stop() for router in routers

exports = { LoggedOutRouter, LoggedInRouter, request, jsdom, url, $ }
exports[key] = value for key, value of models

module.exports = exports
