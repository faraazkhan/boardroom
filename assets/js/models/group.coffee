class boardroom.models.Group extends Backbone.Model

  idAttribute: '_id'

  initialize: (attributes, options) ->
    attributes ||= {}
    cards = new Backbone.Collection _.map(attributes.cards, (card) ->
      new boardroom.models.Card card
    )
    super attributes, options
    @set 'cards', cards
