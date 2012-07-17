boardroomFactory = function(socket, boardInfo) {
  boardroom = {
    max_z: 1,

    moveToTop: function(card) {
      if (parseInt($(card).css('z-index')) === boardroom.max_z) {
        return;
      }
      $(card).css('z-index', ++boardroom.max_z);
    },

    group: {
      addTo: function($card, $targetCard) {
        var cardId = $card.attr('id');
        var cardGroupId = $card.data('group-id');
        var targetGroupId = $targetCard.data('group-id');
        if (targetGroupId) {
          boardroom.group.remove($card);

          boardInfo.groups[targetGroupId].cardIds.push(cardId);
          $card.data('group-id', targetGroupId);
          socket.emit('updateGroup', {boardName: boardInfo.name, _id: targetGroupId, cardIds: boardInfo.groups[targetGroupId].cardIds});
          console.log('added ' + targetGroupId);

          boardroom.group.layOut(targetGroupId);
        } else {
          if (cardGroupId) {
            boardInfo.groups[cardGroupId].cardIds.splice(boardInfo.groups[cardGroupId].cardIds.indexOf(cardId), 1);
            socket.emit('updateGroup', {boardName: boardInfo.name, _id: cardGroupId, cardIds: boardInfo.groups[cardGroupId].cardIds});
          }

          socket.emit('createGroup', {boardName: boardInfo.name, cardIds: [$targetCard.attr('id'), cardId]});
          console.log('create');
        }
      },
      remove: function($card) {
        var cardId = $card.attr('id');
        var cardGroupId = $card.data('group-id');
        if (cardGroupId) {
            console.log('removed ' + cardId + ' from ' + cardGroupId);
            boardInfo.groups[cardGroupId].cardIds.splice(boardInfo.groups[cardGroupId].cardIds.indexOf(cardId), 1);
            socket.emit('updateGroup', {boardName: boardInfo.name, _id: cardGroupId, cardIds: boardInfo.groups[cardGroupId].cardIds});
          }
      },
      onCreated: function(data) {
        console.log('created ' + data._id);

        boardInfo.groups[data._id] = {cardIds: data.cardIds};
        data.cardIds.forEach(function(cardId) {
          $('#' + cardId).data('group-id', data._id);
        })
        boardroom.group.layOut(data._id);
      },
      layOut: function(id) {
        var cardIds = boardInfo.groups[id].cardIds;
        var origin = $('#' + cardIds[0]).offset();
        boardroom.moveToTop($('#' + cardIds[0]));

        cardIds.slice(1).forEach(function(cardId) {
          origin = {
            left: origin.left + 15,
            top:  origin.top  + 36
          };
          $card = $('#' + cardId);
          $card.offset(origin);
          socket.emit('move', {_id:cardId, x:$card[0].offsetLeft, y:$card[0].offsetTop, board_name:boardInfo.name, author:boardInfo.user_id});
          socket.emit('move_commit', {_id:cardId, x:$card[0].offsetLeft, y:$card[0].offsetTop, board_name:boardInfo.name, author:boardInfo.user_id,});
          boardroom.moveToTop($card);
        });
      }
    }
  }

  return boardroom;
}