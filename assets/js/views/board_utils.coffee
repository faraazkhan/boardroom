window.boardUtils = (socket, boardInfo) ->
  boardroom =
    max_z: 1

    moveToTop: (card) ->
      return if parseInt($(card).css('z-index')) == boardroom.max_z
      $(card).css('z-index', ++boardroom.max_z)

    group:
      addTo: ($card, $targetCard) ->
        $card.off('mousedown')
        $card.followDrag(boardroom.dragOptions($card))

        cardId = $card.attr('id')
        cardGroupId = $card.data('group-id')
        targetGroupId = $targetCard.data('group-id')

        boardroom.group.remove $card, boardroom.group.emitRemoval

        if targetGroupId
          boardInfo.groups[targetGroupId].cardIds.push(cardId)
          $card.data 'group-id', targetGroupId
          socket.emit 'updateGroup', {boardName: boardInfo.name, _id: targetGroupId, cardIds: boardInfo.groups[targetGroupId].cardIds}
          boardroom.group.layOut(targetGroupId)
        else
          socket.emit('createGroup', {boardName: boardInfo.name, cardIds: [$targetCard.attr('id'), cardId]})

      remove: ($card, callback) ->
        cardId = $card.attr 'id'
        cardGroupId = $card.data 'group-id'
        if cardGroupId
          boardInfo.groups[cardGroupId].cardIds.splice boardInfo.groups[cardGroupId].cardIds.indexOf(cardId), 1
          if boardInfo.groups[cardGroupId].cardIds.length == 0
            delete boardInfo.groups[cardGroupId]
            $('#' + cardGroupId + "-name").remove()
          $card.data('group-id', null)
          if (callback) then callback(cardGroupId, cardId)

      onCreatedOrUpdated: (data) ->
        boardInfo.groups[data._id] ||= {}
        if data.cardIds
          boardInfo.groups[data._id].cardIds = data.cardIds
          data.cardIds.forEach (cardId) ->
            $('#' + cardId).data 'group-id', data._id
        if data.name
          boardInfo.groups[data._id].name = data.name
          name_id = data._id + "-name"
          if $("#" + name_id).length
            $("#" + name_id).text(data.name)
          else
            $("<div id='#{name_id}' class='stack-name'>#{data.name}</div>").appendTo $(".board")
        boardroom.group.layOut data._id

      layOut: (id) ->
        cardIds = boardInfo.groups[id].cardIds
        origin = $('#' + cardIds[0]).offset()
        boardroom.moveToTop $('#' + cardIds[0])

        $("#" + id + "-name").offset
          left: origin.left,
          top: origin.top - 20

        cardIds.slice(1).forEach (cardId) ->
          origin =
            left: origin.left + 15
            top:  origin.top  + 36

          $card = $('#' + cardId)
          $card.offset origin
          socket.emit 'move', {_id:cardId, x:$card[0].offsetLeft, y:$card[0].offsetTop, board_name:boardInfo.name, author:boardInfo.user_id}
          socket.emit 'move_commit', {_id:cardId, x:$card[0].offsetLeft, y:$card[0].offsetTop, board_name:boardInfo.name, author:boardInfo.user_id}
          boardroom.moveToTop $card

      emitRemoval: (cardGroupId, cardId) ->
        socket.emit 'removeCard',
          boardName: boardInfo.name,
          _id: cardGroupId,
          cardId: cardId,
          cardIds: boardInfo.groups[cardGroupId] && boardInfo.groups[cardGroupId].cardIds || []

    grouping : (e) ->
      # disabling this feature for now
      return

      $activeCard = $(e.target).closest '.card'

      sorted = $('.card').not($activeCard).toArray().sort (first, second) ->
        $(second).css('z-index') - $(first).css('z-index')

      sorted.some (card) ->
        $card = $(card)
        if $card.containsPoint e.pageX, e.pageY
          $activeCard.addClass 'group-intent-source'
          $card.addClass 'group-intent-target'
          $activeCard.add($card).addClass 'group-intent'

          $activeCard.off '.group'
          $activeCard.on 'mouseup.group', () ->
            $activeCard.add($card).removeClassMatching /group-intent.*/g
            $activeCard.off '.group'
            boardroom.group.addTo $activeCard, $card

          $activeCard.on 'mousemove.group', (e) ->
            if !$card.containsPoint e.pageX, e.pageY
              $activeCard.add($card).removeClassMatching /group-intent.*/g
              $activeCard.off '.group'

          return true ## break out of loop

    card:
      onMouseDownHelper: (x, y) ->
        deltaX = x - @offsetLeft
        deltaY = y - @offsetTop
        dragged = @id
        hasMoved = false
        $card = $(@)

        location = ->
          card = $("##{dragged}")[0]
          _id: dragged
          x: card.offsetLeft
          y: card.offsetTop
          board_name: window.board.name
          author: window.board.user_id
          moved_by: window.board.user_id

        onMousePause = $('.card').onMousePause(boardroom.grouping, 400)

        mousemove = (e) ->
          hasMoved = true
          $("##{dragged}").css 'top', e.clientY - deltaY
          $("##{dragged}").css 'left', e.clientX - deltaX
          socket.emit 'move', location()
          false

        mouseup = ->
          onMousePause.off()
          $(window).unbind 'mousemove', mousemove
          $(window).unbind 'mouseup', mouseup
          socket.emit 'move_commit', location()

        $(window).mousemove mousemove
        $(window).mouseup mouseup
        boardroom.moveToTop @
        false

      onMouseDown: (e) ->
        return true if $(e.target).is('textarea')
        boardroom.card.onMouseDownHelper.call(e.target, e.clientX, e.clientY)
  boardroom
