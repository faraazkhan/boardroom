ApplicationController = require './application'
Board = require './../models/board'
BoardsController = require './boards'

class HomeController extends ApplicationController
  index: (request, response) =>
    return response.redirect request.session.post_auth_url if request.session?.post_auth_url?.length > 1
    try
      userId = request.user.id
      Board.findByUserId userId, (err, createdBoards)->
        createdBoards ?= []
        Board.collaboratedBy request.session.user_id, (err, collaboratedBoards)->
          collaboratedBoards ?= []
          if (createdBoards.length + collaboratedBoards.length > 0)
            cmp = (a, b) -> a.name.toLowerCase().localeCompare b.name.toLowerCase()
            response.render 'index',
              user: request.user
              created: createdBoards.sort cmp
              collaborated: collaboratedBoards.sort cmp
          else # automatically create the user's first board
            boardsController = new BoardsController
            alias = request.user.alias()
            board = boardsController.build "#{alias}'s board", request.user, alias, (err, board)->
              response.redirect "/boards/#{board.id}"
    catch error
      return @throw500 response, error

module.exports = HomeController
