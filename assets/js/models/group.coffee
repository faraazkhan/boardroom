class boardroom.models.Group extends Backbone.Model
  idAttribute: '_id'

  defaults:
    name: ''

  initialize: (attributes, options) ->
    cards = new Backbone.Collection _.map(attributes?.cards, (card) -> new boardroom.models.Card(card))
    cards.each (card) => card.set 'group', @, { silent: true }
    @set 'cards', cards
    cards.on 'remove', (card, cards, options) =>
      unless options?.rebroadcast
        @delete options if cards.length == 0

  cards: -> @get 'cards'
  board: -> @get 'board'
  currentUser: -> @board().currentUser()
  currentUserId: -> @board().currentUserId()

  findCard: (id) ->
    @cards().find (card) -> card.id == id

  findCardByCid: (cid) ->
    @cards().find (card) -> card.cid == cid

  moveTo: (x, y) ->
    @set {x, y}

  bringForward: ->
    maxZ = @board().maxZ()
    @set('z', maxZ + 1) unless @get('z') == maxZ

  createCard: (data)->
    card = new boardroom.models.Card
      group: @
      groupId: @id
      creator: @currentUserId()
      authors: [ @currentUserId() ]
    @cards().add card

  dropCard: (id) =>
    card = @board().findCard id
    card.set 'groupId', @id
    card.drop()

  dropGroup: (id) =>
    @board().mergeGroups @id, id

  hover: =>
    @set 'hover', true

  blur: =>
    @set 'hover', false

  delete: =>
    groups = @board().groups()
    groups.remove @
    @trigger 'destroy', @, groups, {} unless options?.rebroadcast

  realize: (group) =>
    updates =
      _id: group.id
      created: group.get 'created'
      updated: group.get 'updated'
    @set updates
    @onSaved @ if @onSaved?
    delete @onSaved
