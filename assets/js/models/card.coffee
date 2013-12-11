class boardroom.models.Card extends Backbone.Model
  idAttribute: '_id'

  defaults:
    text: ''
    authors: []
    plusAuthors: []
    colorIndex: 2

  initialize: (attributes, options) ->
    @.on 'change:groupId', @moveToGroup, @

  group: -> @get 'group'
  board: -> @group().board()
  currentUser: -> @board().currentUser()
  currentUserId: -> @board().currentUserId()

  moveTo: (x, y) ->
    @set { x, y }

  # we are doing an optimization.  instead of letting the remove() and add() handle the
  # move (via listeners in the views), we are making those silent and triggering a
  # special 'moveToGroup' event.  this will ultimately cause the view to move the existing
  # div from one group to another instead of removing it and creating another.  this will
  # allow one person to be typing on a card while another person moves it to a new group
  # without losing any of the typing.
  moveToGroup: (card, groupId, options) =>
    oldGroup = @group()
    newGroup = @board().findGroup groupId
    moveOptions = _(options).extend { movecard: true }

    # we MUST add this card to the new group BEFORE triggering move:card
    newGroup.cards().add @, moveOptions
    @board().trigger 'move:card', @, oldGroup, newGroup

    # then we can do the rest of the book keeping
    oldGroup.cards().remove @, moveOptions
    @set 'group', newGroup, { silent: true }
    @drop()

  drop: ->
    @unset 'x'
    @unset 'y'
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
