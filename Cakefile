{exec} = require "child_process"

task "test", "run tests", ->
  exec "NODE_ENV=test 
    ./node_modules/.bin/mocha 
    --compilers coffee:coffee-script
    --require coffee-script 
    --require test/test-helper.coffee
    --colors
  ", (err, output) ->
    throw err if err
    console.log output
