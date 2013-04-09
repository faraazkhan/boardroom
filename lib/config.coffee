express = require 'express'
cookies = require 'cookie-sessions'
logger = require './services/logger'
pipeline = require './services/asset_pipeline'

configure = (app) ->
  app.use redirectHandler
  app.set 'views', "#{__dirname}/views"
  app.set 'view engine', 'jade'

  app.use pipeline.middleware
  app.use express.bodyParser()
  app.use express.static "#{__dirname}/../public"
  app.use cookies(secret: 'a7c6dddb4fa9cf927fc3d9a2c052d889', session_key: 'boardroom')
  app.use catchPathErrors

catchPathErrors = (error, request, response, next) ->
  logger.error -> error.message
  if error.stack
    console.error error.stack.join("\n")
  response.render '500', status: 500, error: error

redirectHandler = (request, response, next) ->
  if request.host.match /.*betterthanstickies.com$/
    url = 'http://boardroom.carbonfive.com' + request.url
    response.redirect(url)
  else
    next()

module.exports = configure
