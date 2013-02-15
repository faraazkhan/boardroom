class boardroom.models.Card extends Backbone.Model
  idAttribute: '_id'

  defaults:
    text: ''
    authors: []
    plusAuthors: []
    colorIndex: 2

  initialize: (attributes, options) ->
    @.on 'change:groupId', (card, groupId, options) =>
      @group().get('cards').remove @, options
      @board().findGroup(groupId).cards().add @, options
      @drop()
      @touch()

  group: -> @get 'group'
  board: -> @group().board()
  currentUser: -> @board().currentUser()

  moveTo: (x, y) ->
    @set { x, y }
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
