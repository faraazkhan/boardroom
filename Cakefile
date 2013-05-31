{ exec } = require 'child_process'

execCmd = (cmd) ->
  cmdProcess = exec cmd
  cmdProcess.stdout.pipe process.stdout, end: false
  cmdProcess.stderr.pipe process.stderr, end: false
  cmdProcess.on 'exit', (code) ->
    if code then process.exit code

task 'spec:scratch', 'Run all specs in spec/server/**/scratch_spec', ->
  execCmd 'NODE_ENV=test ./node_modules/.bin/jasmine-node --captureExceptions --coffee spec/lib/**/*scratch_spec.coffee'

task 'spec:client', 'Run all specs in spec/client', ->
  execCmd 'NODE_ENV=test jasmine-headless-webkit --color'

task 'spec:server', 'Run all specs in spec/server', ->
  execCmd 'NODE_ENV=test ./node_modules/.bin/jasmine-node --captureExceptions --coffee spec/lib'

task 'spec:models', 'Run all specs in spec/server/models', ->
  execCmd 'NODE_ENV=test ./node_modules/.bin/jasmine-node --captureExceptions --coffee spec/lib/models'

task 'spec:services', 'Run all specs in spec/server/models', ->
  execCmd 'NODE_ENV=test ./node_modules/.bin/jasmine-node --captureExceptions --coffee spec/lib/services'

task 'spec:controllers', 'Run all specs in spec/server/models', ->
  execCmd 'NODE_ENV=test ./node_modules/.bin/jasmine-node --captureExceptions --coffee spec/lib/controllers'


task 'spec', 'Run all client and server specs', ->
  invoke 'spec:client'
  invoke 'spec:server'

task 'nodemon', 'run the server with nodemon', ->
  execCmd "./node_modules/.bin/nodemon -e coffee index.js"
