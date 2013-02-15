console.log "Starting boardroom - #{new Date()}"

Migrator = require './migrator'
migrator = new Migrator

migrator.migrate (error) ->
  throw error if error?
  Router = require './router'
  router = new Router
  router.start()
