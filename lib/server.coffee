logger = require './utils/logger'
logger.setLevel 'info'
logger.warn -> 'Starting Boardroom'

Migrator = require './migrator'
migrator = new Migrator

migrator.migrate (error) ->
  throw error if error?
  Router = require './router'
  router = new Router
  router.start()
