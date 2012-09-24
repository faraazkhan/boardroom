fs = require 'fs'

class Migrator
  constructor: ->
    @migrations = @loadMigrations()

  migrate: (callback) ->
    next = (error) =>
      return callback error if error?
      return callback() if @migrations.length == 0
      migration = @migrations.shift()
      console.log "[Migrate] #{migration.split('/').pop()}"
      m = require migration
      m.up next
    next()

  loadMigrations: ->
    fs.readdirSync("#{@migrationsDir()}").filter (file) ->
      file.match(new RegExp('^\\d+.*\\.(js|coffee)$'))
    .sort().map (file) =>
      "#{@migrationsDir()}/#{file}"

  migrationsDir: ->
    "#{__dirname}/../migrations"

module.exports = Migrator
