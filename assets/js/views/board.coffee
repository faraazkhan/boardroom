class boardroom.views.Board extends boardroom.views.Base
  el: '.board'
  className: 'board'

  events:
    'dblclick'  : 'hiRequestNewCard'

  touchEvents:
    'doubletap' : 'hiRequestNewCard'

  initialize: (attributes) ->
    super attributes
    @render()
    @initializeGroups()
    @initializeDroppable()
    @resizeHTML()
    $(window).resize => @resizeHTML()

    @model.on 'change:status', @updateStatus, @
    @model.on 'move:card', @moveCard, @

    @model.groups().on 'add', @displayNewGroup, @
    @model.groups().on 'remove', @removeGroup, @

    @updateStatus @, @model.get('status')

  initializeGroups: ->
    @groupViews = []
    @model.groups().each @displayNewGroup, @

  initializeDroppable: ->
    @$el.droppable
      threshold: Math.max @$el.height(), @$el.width()
      priority: 1
      onDrop: (mouseEvent, target) =>
        id = $(target).attr('id')
        @model.dropCard(id)  if $(target).is('.card')
        @model.dropGroup(id) if $(target).is('.group')

  ###
      render
  ###

  render: ->
    @$el.hammer()

  statusModalDiv: ->
    @$('#connection-status-modal')

  statusDiv: ->
    @$('#connection-status')

  updateStatus: (board, status, options) =>
    @statusDiv().html status
    if status then @statusModalDiv().show() else @statusModalDiv().hide()

  findGroupView: (group) =>
    _(@groupViews).find (gv) => gv.model == group

  findGroupViewByCid: (cid) =>
    _(@groupViews).find (gv) => gv.model.cid == cid

  displayNewGroup: (group, options) =>
    group.set 'board', @model, { silent: true }
    return if @findGroupViewByCid(group.cid)?  # it's already in there +++ update the div's id
    groupView = new boardroom.views.Group { model: group }
    @groupViews.push groupView

    @$el.append groupView.el
    groupView.trigger 'attach'
    @resizeHTML()

  removeGroup: (group, options) =>
    groupView = @findGroupView group
    @groupViews.splice @groupViews.indexOf(groupView), 1
    groupView.remove()

  moveCard: (card, oldGroup, newGroup, options) =>
    oldGroupView = @findGroupView oldGroup
    newGroupView = @findGroupView newGroup
    cardView = oldGroupView.findCardView card

    newGroupView.displayExistingCard cardView
    oldGroupView.removeCardView card
    oldGroupView.updateGroupChrome()

  ###
      human interaction event handlers
  ###

  hiRequestNewCard: (e) ->
    event = if e.pageX? then e else e.gesture.srcEvent
    return unless event.target.className == 'board'
    offset = @$el.offset()
    @model.createGroup
      x: event.pageX - offset.left
      y: event.pageY - offset.top
