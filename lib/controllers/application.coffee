class ApplicationController
  throw404: (response) =>
    response.writeHead 404,
      'Content-Type': 'text/plain'
    response.write '404 Not Found\n'
    response.end()

  throw500: (response, error) =>
    response.writeHead 500,
      'Content-Type': 'text/plain'
    response.write '500 Error\n'
    response.write error.stack
    response.end()

module.exports = ApplicationController
