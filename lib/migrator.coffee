fs = require 'fs'

class Migrator
  constructor: ->
    @migrations = @loadMigrations()

  migrate: ->
    next = (error) =>
      throw error if error?
      return if @migrations.length == 0
      migration = @migrations.shift()
      console.log "[Migrate] #{migration}"
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
