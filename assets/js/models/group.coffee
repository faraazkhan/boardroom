class boardroom.models.Group extends Backbone.Model

  idAttribute: '_id'

  initialize: (attributes, options) ->
    attributes ||= {}
    cards = new Backbone.Collection _.map(attributes.cards, (card) ->
      new boardroom.models.Card card
    )
    super attributes, options
    @set 'cards', cards

  moveTo: (x, y) ->
    @set
      x: x
      y: y
      author: @get('board').get('user_id')

  bringForward: ->
    maxZ = @get('board').maxZ()
    @set('z', maxZ + 1) unless @get('z') == maxZ
