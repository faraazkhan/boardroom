class boardroom.models.Card extends Backbone.Model
  idAttribute: '_id'

  defaults:
    text: ''
    authors: []
    plusAuthors: []

  initialize: (attributes, options) ->
    @.on 'change:groupId', (card, groupId, options) =>
      console.log "card.on change:groupId - #{groupId}"
      @get('group').get('cards').remove @, options
      @get('group').get('board').findGroup(groupId).get('cards').add @, options
      @touch()

  moveTo: (x, y) ->
    @set { x, y }
    @touch()

  type: (text) ->
    @set { text }
    @touch()

  colorize: (colorIndex) ->
    @set { colorIndex }
    @touch()

  focus: () ->
    @get('group').bringForward()

  delete: ->
    cards = @get('group').get('cards')
    cards.remove @
    @trigger 'destroy', @, cards, {}

  plusOne: ->
    @get('group').bringForward()
    plusAuthors = @get 'plusAuthors'
    author = @currentUser()
    unless plusAuthors.indexOf(author) >= 0
      clone = _.clone(plusAuthors) # need to clone other backbone won't trigger a change event
      clone.push author
      @set 'plusAuthors', clone
    @touch()

  currentUser: ->
    @get('group').get('board').get('user_id')

  touch: =>
    authors = @get 'authors'
    author = @currentUser()
    unless authors.indexOf(author) >= 0
      clone = _.clone(authors)
      clone.push author
      @set 'authors', clone
