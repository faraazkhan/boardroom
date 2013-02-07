class boardroom.models.Card extends Backbone.Model
  idAttribute: '_id'

  defaults:
    text: ''

  initialize: (attributes, options) ->
    @.on 'change:groupId', (card, groupId, options) =>
      console.log "card.on change:groupId - #{groupId}"
      @get('group').get('cards').remove @, options
      @get('group').get('board').findGroup(groupId).get('cards').add @, options

  delete: ->
    cards = @get('group').get('cards')
    cards.remove @
    @trigger 'destroy', @, cards, {}
