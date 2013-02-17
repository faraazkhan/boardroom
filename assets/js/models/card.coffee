class boardroom.models.Card extends Backbone.Model
  idAttribute: '_id'

  defaults:
    text: ''
    authors: []
    plusAuthors: []
    colorIndex: 2

  initialize: (attributes, options) ->
    @.on 'change:groupId', (card, groupId, options) => @moveToGroup groupId

  group: -> @get 'group'
  board: -> @group().board()
  currentUser: -> @board().currentUser()

  moveTo: (x, y) ->
    @set { x, y }
    @touch()

  # we are doing an optimization.  instea of letting the remove() and add() handle the
  # move (via listeners in the views), we are making those silent and triggering a
  # special 'moveToGroup' event.  this will ultimately cause the view to move the existing
  # div from one group to another instead of removing it and creating another.  this will
  # allow one person to be typing on a card while another person moves it to a new group
  # without losing any of the typing.
  moveToGroup: (groupId) =>
    oldGroup = @group()
    newGroup = @board().findGroup groupId
    @board().trigger 'move:card', @, oldGroup, newGroup
    oldGroup.cards().remove @, { movecard: true }
    newGroup.cards().add @, { movecard: true }
    @set 'group', newGroup, { silent: true }
    @drop()
    @touch()

  drop: ->
    @unset 'x'
    @unset 'y'

  type: (text) ->
    @set { text }
    @touch()

  colorize: (colorIndex) ->
    @set { colorIndex }
    @touch()

  focus: () ->
    @group().bringForward()

  delete: ->
    cards = @group().cards()
    cards.remove @
    @trigger 'destroy', @, cards, {}

  plusOne: ->
    @group().bringForward()
    plusAuthors = @get 'plusAuthors'
    author = @currentUser()
    unless plusAuthors.indexOf(author) >= 0
      clone = _.clone(plusAuthors) # need to clone other backbone won't trigger a change event
      clone.push author
      @set 'plusAuthors', clone

  touch: =>
    authors = @get 'authors'
    author = @currentUser()
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
