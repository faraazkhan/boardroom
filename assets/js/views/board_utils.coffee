window.boardUtils = (socket, boardInfo) ->
  boardroom =
    max_z: 1

    moveToTop: (card) ->
      return if parseInt($(card).css('z-index')) == boardroom.max_z
      $(card).css('z-index', ++boardroom.max_z)

    card:
      onMouseDownHelper: (x, y) ->
        $card = $(@).closest '.card'
        card = $card[0]
        deltaX = x - card.offsetLeft
        deltaY = y - card.offsetTop
        dragged = card.id
        hasMoved = false

        location = ->
          card = $("##{dragged}")[0]
          _id: dragged
          x: card.offsetLeft
          y: card.offsetTop
          author: window.board.user_id

        mousemove = (e) ->
          hasMoved = true
          $("##{dragged}").css 'top', e.clientY - deltaY
          $("##{dragged}").css 'left', e.clientX - deltaX
          socket.emit 'card.update', location()
          false

        mouseup = ->
          $(window).unbind 'mousemove', mousemove
          $(window).unbind 'mouseup', mouseup

        $(window).mousemove mousemove
        $(window).mouseup mouseup
        boardroom.moveToTop card
        false

      onMouseDown: (e) ->
        return true if $(e.target).is('textarea')
        boardroom.card.onMouseDownHelper.call(e.target, e.clientX, e.clientY)
  boardroom
