class boardroom.views.Board extends boardroom.views.Base
  el: '.board'
  className: 'board'
  groupViews: []

  events:
    'dblclick': 'hiRequestNewCard'

  initialize: (attributes) ->
    super attributes
    @initializeGroups()
    @initializeDroppable()
    @resizeHTML()
    $(window).resize => @resizeHTML()

    @model.on 'change:status', @updateStatus, @

    @model.get('groups').on 'add', (group) => @displayNewGroup(group)
    @model.get('groups').on 'remove', (group) => @removeGroup(group)

  initializeGroups: ->
    @model.get('groups').each (group) => @displayNewGroup(group)

  initializeDroppable: ->
    @$el.droppable
      threshold: Math.max @$el.height(), @$el.width()
      priority: 1
      onHover: (event, target) =>
        @$el.addClass 'stackable' unless @$el.is 'stackable'
      onBlur: (event, target) =>
        @$el.removeClass 'stackable'
      onDrop: (mouseEvent, target) =>
        console.log "board.onDrop"
        id = $(target).attr('id')
        @model.dropCard(id)  if $(target).is('.card')
        @model.dropGroup(id) if $(target).is('.group')
        @$el.removeClass 'stackable'

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

  displayNewGroup: (data) ->
    data.set 'board', @model, { silent: true }
    groupView = new boardroom.views.Group { model: data }
    @$el.append groupView.el
    @resizeHTML()

  removeGroup: (group) =>
    $("##{group.id}").remove()

  ###
      human interaction event handlers
  ###

  hiRequestNewCard: (event) ->
    return unless event.target.className == 'board'
    @model.createGroup(@coordinateOfEvent event)
