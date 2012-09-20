class ApplicationController

  throw404: (response) =>
    response.writeHead 404,
      'Content-Type': 'text/plain'
    response.write '404 Not Found\n'
    response.end()

module.exports = ApplicationController
