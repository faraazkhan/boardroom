class boardroom.models.Group extends Backbone.Model

  idAttribute: '_id'

  defaults:
    pendingCards: new Backbone.Collection()

  initialize: (attributes, options) ->
    attributes ||= {}
    cards = new Backbone.Collection _.map(attributes.cards, (card) ->
      new boardroom.models.Card card
    )
    super attributes, options
    @set 'cards', cards

  cards: ()-> @get('cards')

  findCard: (id) ->
    @get('cards').find (card) ->
      card.id == id

  moveTo: (x, y) ->
    @set
      x: x
      y: y
      author: @get('board').get('user_id')

  bringForward: ->
    maxZ = @get('board').maxZ()
    @set('z', maxZ + 1) unless @get('z') == maxZ

  createCard: (data)->
    @cards().add(new boardroom.models.Card(data))
