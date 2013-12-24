class boardroom.models.Card extends Backbone.Model
  idAttribute: '_id'

  defaults:
    text: ''
    authors: []
    plusAuthors: []
    colorIndex: 2

  initialize: (attributes, options) ->
    @.on 'change:groupId', @updateGroupId, @
    @.on 'change:order',   @updateOrder,   @

  group: -> @get 'group'
  board: -> @group().board()
  currentUser: -> @board().currentUser()
  currentUserId: -> @board().currentUserId()

  moveTo: (x, y) ->
    @set { x, y }

  updateGroupId: (card, groupId, options) =>
    @board().moveCard card, @group().id, groupId, options

  updateOrder: (card, order, options) =>
    @group().cards().sort()

  drag: ->
    @set 'state', 'dragging'

  drop: ->
    @unset 'x'
    @unset 'y'
    @unset 'state'
    @blur()

  type: (text) ->
    @set { text }
    @touch()

  colorize: (colorIndex) ->
    @set { colorIndex }
    @touch()

  focus: () ->
    @focused = true
    @group().bringForward()

  unfocus: () ->
    @focused = false

  hover: (location) ->
    @set 'hover', location

  blur: ->
    @unset 'hover'

  delete: ->
    cards = @group().cards()
    cards.remove @
    @trigger 'destroy', @, cards, {}

  plusOne: ->
    @group().bringForward()
    plusAuthors = @get 'plusAuthors'
    author = @currentUserId()
    unless plusAuthors.indexOf(author) >= 0
      clone = _.clone(plusAuthors) # need to clone other backbone won't trigger a change event
      clone.push author
      @set 'plusAuthors', clone

  touch: =>
    authors = @get 'authors'
    author = @currentUserId()
    unless authors.indexOf(author) >= 0
      clone = _.clone(authors)
      clone.push author
      @set 'authors', clone

  realize: (card) =>
    updates =
      _id: card.id
      created: card.get 'created'
      updated: card.get 'updated'
    @set updates
