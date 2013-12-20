class boardroom.models.Group extends Backbone.Model
  idAttribute: '_id'

  defaults:
    name: ''

  initialize: (attributes, options) ->
    cards = new Backbone.Collection _.map(attributes?.cards, (card) -> new boardroom.models.Card(card))
    cards.each (card) => card.set 'group', @, { silent: true }
    cards.comparator = @cardSorter
    @set 'cards', cards
    cards.on 'remove', @removeCard, @

  cards: -> @get 'cards'
  board: -> @get 'board'
  currentUser: -> @board().currentUser()
  currentUserId: -> @board().currentUserId()

  cardSorter: (a, b) ->
    orderA = a.get 'order'
    orderB = b.get 'order'
    return orderA - orderB unless orderA == orderB
    if a.get('created') > b.get('created') then 1 else 0

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
      order: @cards().last().get('order') + 1
    @cards().add card

  dropCard: (id, location) =>
    card = @board().findCard id
    @addCards [card], location
    card.drop()
    @blurCards()

  dropGroup: (id, location) =>
    @board().mergeGroups @id, id, location
    @blurCards()

  addCards: (cards, location) =>
    ids = _(cards).pluck 'id'
    ordered = @cards().reject (card) -> _(ids).contains(card.id)
    locCard = _(ordered).find (card) -> card.id == location.id
    locIndex = _(ordered).indexOf locCard
    spliceIndex = if location.position == 'above' then 0 else 1
    ordered.splice (locIndex + spliceIndex), 0, cards...
    card.set('groupId', @id) for card in cards
    _(ordered).each (card, index) -> card.set('order', index)
    @cards().sort()

  removeCard: (card, cards, options) =>
    cards.each (card, index) -> console.log(card.get('text'))
    @cards().each (card, index) -> card.set('order', index)
    unless options?.rebroadcast
      @delete options if cards.length == 0

  hover: (location) =>
    @set 'hover', true
    @cards().each (card) ->
      if card.id == location.id
        card.hover location.position
      else
        card.blur()

  blur: =>
    @set 'hover', false
    @blurCards()

  blurCards: =>
    @cards().each (card) -> card.blur()

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
