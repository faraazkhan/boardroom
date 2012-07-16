boardroom = function(socket) {
  self = {
    groups: {},

    group: {
      addTo: function($card, $targetCard) {
        var cardId = $card.attr('id');
        var cardGroupId = $card.data('group-id');
        var targetGroupId = $targetCard.data('group-id');
        if (targetGroupId) {
          if (cardGroupId) {
            console.log('removed ' + cardId + ' from ' + cardGroupId);
            self.groups[cardGroupId].splice(self.groups[cardGroupId].indexOf(cardId), 1);
            socket.emit('updateGroup', {_id: cardGroupId, cardIds: self.groups[cardGroupId]});
          }

          self.groups[targetGroupId].push(cardId);
          $card.data('group-id', targetGroupId);
          // socket.emit('addToGroup', {_id: targetGroupId, cardId: cardId});
          socket.emit('updateGroup', {_id: targetGroupId, cardIds: self.groups[targetGroupId]});
          console.log('added ' + targetGroupId);

          self.group.layOut(targetGroupId);
        } else {
          if (cardGroupId) {
            self.groups[cardGroupId].splice(self.groups[cardGroupId].indexOf(cardId), 1);
            // socket.emit('removeFromGroup', {_id: cardGroupId, cardId: cardId});
            socket.emit('updateGroup', {_id: cardGroupId, cardIds: self.groups[cardGroupId]});
          }
          
          socket.emit('createGroup', {cardIds: [$targetCard.attr('id'), cardId]});
          console.log('create');
        }
      },
      onCreated: function(data) {
        console.log('created ' + data._id);

        self.groups[data._id] = data.cardIds;
        data.cardIds.forEach(function(cardId) {
          $('#' + cardId).data('group-id', data._id);
        })
        self.group.layOut(data._id);
      },
      layOut: function(id) {
        var cardIds = self.groups[id];
        var origin = $('#' + cardIds[0]).offset();

        cardIds.slice(1).forEach(function(cardId) {
          origin = {
            left: origin.left + 15,
            top:  origin.top  + 36
          };
          $card = $('#' + cardId);
          $card.offset(origin);
          socket.emit('move_commit', {_id:cardId, x:$card[0].offsetLeft, y:$card[0].offsetTop});
          // moveToTop($(this));
        });
      }
    }


    // group: function($note, $target) {
    //   if ($target.parent().hasClass('group')) {
    //     $note.appendTo($target.parent());
    //   } else {
    //     $('<div class="group"')
    //   }
    //   var origin = $target.offset()
    //   $note.offset({left: origin.left + 15, top: origin.top + 36});
    //   socket.emit('group', {noteId: $note.attr('id'), targetId: $target.attr('id')})



    //   if ($target.attr('data-group-id')) {
    //     groups[$target.attr('data-group-id')].push($note.attr('id'))
    //     socket.emit('addToGroup', {_id: $target.attr('data-group-id'), cardId: $note.attr('id')})
    //   } else {
    //     socket.emit('createGroup', {cardId: , targetId: });
    //   }
    // },
    // onGroupCreated: function(data) {
    //   groups[data._id] = [data.targetId, data.cardId]
    // },
    // onGroup: function(data) {
    //   var $note = $('#' + data.noteId);
    //   var $target = $('#' + data.targetId);
    //   var origin = $target.offset()
    //   $note.offset({left: origin.left + 15, top: origin.top + 36});
    // }
  }

  return self;
}