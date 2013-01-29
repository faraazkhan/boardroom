fs = require 'fs'
helper = require '../migrations/helper'

class Migrator
  constructor: ->
    @migrations = @loadMigrations()

  migrate: (callback) ->
    next = (error) =>
      return callback error if error?
      if @migrations.length == 0
        helper.disconnect()
        return callback()

      migration = @migrations.shift()
      console.log "[Migrate] #{migration.split('/').pop()}"
      m = require migration
      m.up next

    helper.connect (error) ->
      next error

  loadMigrations: ->
    fs.readdirSync("#{@migrationsDir()}").filter (file) ->
      file.match(new RegExp('^\\d+.*\\.(js|coffee)$'))
    .sort().map (file) =>
      "#{@migrationsDir()}/#{file}"

  migrationsDir: ->
    "#{__dirname}/../migrations"

module.exports = Migrator
