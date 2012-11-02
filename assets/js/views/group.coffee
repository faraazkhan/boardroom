class boardroom.views.Group extends Backbone.View
  className: 'group'
  cardViews: []

  attributes: ->
    id: @model.id

  events: {}

  initialize: (attributes) ->
    { @socket } = attributes
    @initializeCards()

  initializeCards: () ->
    for card in @model.get('cards')
      @displayNewCard card

  findCardView: (id) ->
    _.detect @cardViews, (view) ->
      view.model.id is id

  zIndex: ->
    parseInt(@$el.css('z-index')) || 0

  displayNewCard: (data) ->
    card = new boardroom.models.Card _.extend(data, group: @model)
    cardView = new boardroom.views.Card
      model: card
      socket: @socket
    @$el.append cardView.render().el
    cardView.adjustTextarea()
    @cardViews.push cardView

  render: ->
    @$el
      .css
        left: @model.get('x')
        top: @model.get('y')
        'z-index': @model.get('z')
    @
