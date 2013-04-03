ApplicationController = require './application'
Board = require './../models/board'
BoardsController = require './boards'

class HomeController extends ApplicationController
  index: (request, response) =>
    return response.redirect request.session.post_auth_url if request.session?.post_auth_url?
    try
      user_id = request.session.user_id
      Board.createdBy user_id, (err, createdBoards)->
        createdBoards ?= []
        Board.collaboratedBy user_id, (err, collaboratedBoards)->
          collaboratedBoards ?= []
          if (createdBoards.length + collaboratedBoards.length > 0)
            cmp = (a, b) -> a.name.toLowerCase().localeCompare b.name.toLowerCase()
            response.render 'index',
              user: { user_id }
              created: createdBoards.sort cmp
              collaborated: collaboratedBoards.sort cmp
          else # automatically create the user's first board
            boardsController = new BoardsController
            board = boardsController.build "#{user_id}'s board", user_id, (err, board)->
              response.redirect "/boards/#{board.id}"
    catch error
      return @throw500 response, error

module.exports = HomeController
