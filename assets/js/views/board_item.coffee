class boardroom.views.BoardItem extends Backbone.View
  events:
    'submit form': 'deleteBoard'

  deleteBoard: ->
    confirm 'Are you sure?'
