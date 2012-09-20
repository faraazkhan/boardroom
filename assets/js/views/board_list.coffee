class boardroom.views.BoardList extends Backbone.View
  el: '#boards'

  events:
    'submit ul': 'deleteBoard'

  deleteBoard: ->
    confirm 'WARNING: This will delete all cards this board!!  You cannot get this board back.\n\nAre you sure you want to do this?'
