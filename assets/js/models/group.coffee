class boardroom.models.Group extends boardroom.models.Model

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
    c = new boardroom.models.Card
    c.save()
    c.set('xyz', 'abc')
    c.id = 5
    c.save()

  bringForward: ->
    maxZ = @get('board').maxZ()
    @set('z', maxZ + 1) unless @get('z') == maxZ
