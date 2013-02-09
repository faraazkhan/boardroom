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

    @model.on 'change:status', (board, status, options) => @displayStatus()
    @model.get('groups').on 'add', (group) => @displayNewGroup(group)
    @model.get('groups').on 'remove', (group) => @removeGroup(group)

  initializeSourcePath: ()->
    @sourcePath =
      boardId: @model.id

  initializeGroups: ->
    @model.get('groups').each (group) => @displayNewGroup(group)

  initializeDroppable: ->
    @$el.droppable
      threshold: Math.max @$el.height(), @$el.width()
      onHover: (event, target) =>
        @$el.addClass 'stackable' unless @$el.is 'stackable'
      onBlur: (event, target) =>
        @$el.removeClass 'stackable'
      onDrop: (mouseEvent, target) =>
        id = $(target).attr('id')
        if $(target).is('.card')
          @model.dropCard id
        else if $(target).is('.group')
          @model.dropGroup id
        @$el.removeClass 'stackable'
      shouldBlockHover: (coordinate) =>
        (return true if group.containsPoint(coordinate)) for group in @groupViews
        return false

  sourcePath: ()-> 
    boardId: @model.id

  ###
      render
  ###

  statusModalDiv: ->
    @$('#connection-status-modal')

  statusDiv: ->
    @$('#connection-status')

  displayStatus: ->
    status = @model.get 'status'
    @statusDiv().html status
    if status then @statusModalDiv().show() else @statusModalDiv().hide()

  displayNewGroup: (data) ->
    data.set 'board', @model, { silent: true }

    groupView = new boardroom.views.Group
      model: data
      boardView: @
    @$el.append groupView.el
    @groupViews.push groupView
    @resizeHTML()
    # set the focus if group was just created by this user
    card = groupView.model?.get('cards')?[0]
    @findView(card?._id)?.$('textarea').focus() if @model.get('user_id') is card?.creator

  removeGroup: (group) =>
    $("##{group.id}").remove()

  ###
      human interaction event handlers
  ###

  hiRequestNewCard: (event) ->
    return unless event.target.className == 'board'
    @model.createGroup(@coordinateOfEvent event)
