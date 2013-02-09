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

  cards: -> @get 'cards'
  board: -> @get 'board'
  currentUser: -> @board().currentUser()

  findCard: (id) ->
    @cards().find (card) ->
      card.id == id

  moveTo: (x, y) ->
    @set {x, y}

  bringForward: ->
    maxZ = @board().maxZ()
    @set('z', maxZ + 1) unless @get('z') == maxZ

  createCard: (data)->
    @cards().add(new boardroom.models.Card(data))

  dropCard: (id) =>
    card = @board().findCard id
    card.set 'groupId', @get('_id')
    card.drop()

  dropGroup: (id) =>
    @board().mergeGroups @get('_id'), id

  hover: =>
    @set 'hover', true

  blur: =>
    @set 'hover', false
