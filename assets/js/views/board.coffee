class boardroom.views.Board extends boardroom.views.Base
  el: '.board'
  className: 'board'

  events:
    'dblclick': 'hiRequestNewCard'

  initialize: (attributes) ->
    super attributes
    @initializeGroups()
    @initializeDroppable()
    @resizeHTML()
    $(window).resize => @resizeHTML()

    @model.on 'change:status', @updateStatus, @

    @model.groups().on 'add', @displayNewGroup, @
    @model.groups().on 'remove', @removeGroup, @

  initializeGroups: ->
    @groupViews = []
    @model.groups().each @displayNewGroup, @

  initializeDroppable: ->
    @$el.droppable
      threshold: Math.max @$el.height(), @$el.width()
      priority: 1
      onDrop: (mouseEvent, target) =>
        console.log "board.onDrop"
        id = $(target).attr('id')
        @model.dropCard(id)  if $(target).is('.card')
        @model.dropGroup(id) if $(target).is('.group')

  ###
      render
  ###

  statusModalDiv: ->
    @$('#connection-status-modal')

  statusDiv: ->
    @$('#connection-status')

  updateStatus: (board, status, options) =>
    @statusDiv().html status
    if status then @statusModalDiv().show() else @statusModalDiv().hide()

  displayNewGroup: (group, options) =>
    group.set 'board', @model, { silent: true }
    groupView = new boardroom.views.Group { model: group }
    @groupViews.push groupView

    @$el.append groupView.el
    groupView.trigger 'attach'
    @resizeHTML()

  removeGroup: (group, options) =>
    groupView = _(@groupViews).find (gv) -> gv.model == group
    @groupViews.splice @groupViews.indexOf(groupView), 1
    groupView.remove()

  ###
      human interaction event handlers
  ###

  hiRequestNewCard: (event) ->
    console.log "hiRequestNewCard: #{event.target.className}"
    return unless event.target.className == 'board'
    offset = @$el.offset()
    @model.createGroup
      x: event.pageX - offset.left
      y: event.pageY - offset.top
