window.boardUtils = (socket, boardInfo) ->
  boardroom =
    max_z: 1

    moveToTop: (card) ->
      return if parseInt($(card).css('z-index')) == boardroom.max_z
      $(card).css('z-index', ++boardroom.max_z)

  boardroom
