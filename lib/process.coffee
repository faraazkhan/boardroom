process.on "uncaughtException", (error) ->
  console.error("Uncaught exception: " + error.message)
  if (error.stack)
    console.log '\nStacktrace:'
    console.log '===================='
    console.log error.stack
