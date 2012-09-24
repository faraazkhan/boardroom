Migrator = require './lib/migrator'
migrator = new Migrator

migrator.migrate (error) ->
  throw error if error?
  Router = require './lib/router'
  router = new Router
  router.start()
