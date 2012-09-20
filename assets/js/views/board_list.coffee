class boardroom.views.BoardList extends Backbone.View
  el: '#boards'

  events:
    'submit ul': 'deleteBoard'

  deleteBoard: ->
    confirm 'Are you sure?'
