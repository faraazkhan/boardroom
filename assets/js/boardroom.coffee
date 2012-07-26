window.boardroomFactory = (socket, boardInfo) ->
  boardroom =
    max_z : 1

    dragOptions : ($card) ->
      opts =
        onMouseMove: () ->
          socket.emit 'move', {_id: $card.id, x: $card.position().left, y: $card.position().top, board_name: boardInfo.name, author:boardInfo.user_id}
        position : (dx, dy, x, y, e) ->
          distance = Math.sqrt dx*dx + dy*dy
          if distance < 100
            return left: Math.floor(x - dx*(1-distance/100/5)), top: Math.floor(y - dy*(1-distance/100/5))
          else
            boardroom.group.remove $card, boardroom.group.emitRemoval
            $(window).add($card).off '.followDrag'
            $card.mousedown(boardroom.card.onMouseDown)
            socket.emit 'move_commit', {_id: $card.id, x: $card.position().left, y:$card.position().top, board_name:boardInfo.name, author:boardInfo.user_id}
            $card.offset({left: x, top: y});
            boardroom.card.onMouseDownHelper.call $card[0], e.pageX, e.pageY
            return left: x, top: y
      return opts

    moveToTop: (card) ->
      if parseInt($(card).css('z-index')) == boardroom.max_z then return
      $(card).css('z-index', ++boardroom.max_z)

    group:
      addTo: ($card, $targetCard) ->
        $card.off('mousedown');
        $card.followDrag(boardroom.dragOptions($card));

        cardId = $card.attr('id');
        cardGroupId = $card.data('group-id');
        targetGroupId = $targetCard.data('group-id');

        boardroom.group.remove $card, boardroom.group.emitRemoval

        if targetGroupId
          boardInfo.groups[targetGroupId].cardIds.push(cardId);
          $card.data 'group-id', targetGroupId
          socket.emit 'updateGroup', {boardName: boardInfo.name, _id: targetGroupId, cardIds: boardInfo.groups[targetGroupId].cardIds}
          boardroom.group.layOut(targetGroupId);
        else
          socket.emit('createGroup', {boardName: boardInfo.name, cardIds: [$targetCard.attr('id'), cardId]});

      remove: ($card, callback) ->
        cardId = $card.attr 'id'
        cardGroupId = $card.data 'group-id'
        if cardGroupId
          console.log 'removed ' + cardId + ' from ' + cardGroupId
          boardInfo.groups[cardGroupId].cardIds.splice boardInfo.groups[cardGroupId].cardIds.indexOf(cardId), 1
          if boardInfo.groups[cardGroupId].cardIds.length == 0
            delete boardInfo.groups[cardGroupId]
            $('#' + cardGroupId + "-name").remove()
          $card.data('group-id', null)
          if (callback) then callback(cardGroupId, cardId)

      onCreatedOrUpdated: (data) ->
        boardInfo.groups[data._id] = {cardIds: data.cardIds, name: data.name}
        data.cardIds.forEach (cardId) ->
          $('#' + cardId).data 'group-id', data._id
        name_id = data._id + "-name";
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
      $activeCard = $(e.target).closest '.card'

      sorted = $('.card').not($activeCard).toArray().sort (first, second) ->
        $(second).css('z-index') - $(first).css('z-index')

      sorted.some (card) ->
        $card = $(card);
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
        deltaX = x-this.offsetLeft
        deltaY = y-this.offsetTop
        dragged = this.id
        hasMoved = false
        $card = $(this)

        location = () ->
          card = $('#'+dragged)[0]
          return {_id:dragged, x:card.offsetLeft, y:card.offsetTop, board_name:window.board.name, author:window.board.user_id, moved_by:window.board.user_id}

        onMousePause = $('.card').onMousePause(boardroom.grouping, 400)

        mousemove = (e) ->
          hasMoved = true;
          $('#'+dragged).css 'top', e.clientY - deltaY
          $('#'+dragged).css 'left', e.clientX - deltaX
          socket.emit('move', location())

        mouseup = (e) ->
          onMousePause.off()
          $(window).unbind 'mousemove', mousemove
          $(window).unbind 'mouseup', mouseup
          socket.emit 'move_commit', location()

        $(window).mousemove mousemove
        $(window).mouseup mouseup
        boardroom.moveToTop this

      onMouseDown: (e) ->
        return true if $(e.target).is('textarea:focus')
        boardroom.card.onMouseDownHelper.call(e.target, e.clientX, e.clientY)

  return boardroom