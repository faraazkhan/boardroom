ApplicationController = require './application'

class ContentsController extends ApplicationController
  styles: (request, response) =>
    response.render 'styles', {layout: false}

module.exports = ContentsController
