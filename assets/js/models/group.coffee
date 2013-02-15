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
    cards.on 'remove', (card, cards, options) =>
      unless options?.rebroadcast
        @delete options if cards.length == 0

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
    card = new boardroom.models.Card
      groupId: @get '_id'
      creator: @currentUser()
      authors: [ @currentUser() ]
    @get('pendingCards').add card

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

  delete: =>
    groups = @board().groups()
    groups.remove @
    @trigger 'destroy', @, groups, {} unless options?.rebroadcast
