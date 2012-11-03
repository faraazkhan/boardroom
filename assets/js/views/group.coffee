class boardroom.views.Group extends Backbone.View
  className: 'group'
  cardViews: []

  attributes: ->
    id: @model.id

  events: {}

  initialize: (attributes) ->
    @$el.data 'view', @
    { @socket } = attributes
    @initializeCards()

  initializeCards: () ->
    cards = @model.get('cards')
    @displayNewCard card for card in cards if cards

  findView: (id) ->
    $("##{id}").data('view')

  zIndex: ->
    parseInt(@$el.css('z-index')) || 0

  displayNewCard: (data) ->
    bindings = 
      'group': @model
      'board': (@model.get 'board') 
    if data.set? # check if data is a BackboneModel or not
      data.set bindings
      card = data
    else 
      card = new boardroom.models.Card _.extend(data, bindings)
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
