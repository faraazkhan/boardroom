{ withCollection,
  errorWrapper,
  safe,
  BSON } = require './db'

saveCard = (card, callback) ->
  withCollection 'cards', (cards) ->
    card.authors = []
    cards.save card, safe(callback), errorWrapper callback

updateCard = (card, callback) ->
  withCollection 'cards', (cards) ->
    cards.find {_id:new BSON.ObjectID(card._id) }, errorWrapper ( cursor ) ->
      cursor.each errorWrapper ( existingCard ) ->
        if existingCard == null then return
        if card.x then existingCard.x = card.x
        if card.y then existingCard.y = card.y
        if card.text then existingCard.text = card.text
        if card.colorIndex then existingCard.colorIndex = card.colorIndex
        if card.deleted != null then existingCard.deleted = card.deleted
        if card.author && (! existingCard.authors || ! (existingCard.authors.indexOf(card.author)>-1))
          (existingCard.authors = existingCard.authors || []).push( card.author )
        cards.save existingCard, safe(callback), errorWrapper callback

removeCard = (card, callback) ->
  withCollection 'cards', (cards) -> cards.remove { _id: new BSON.ObjectID(card._id) }, errorWrapper callback

findCards = (criteria, reducer) ->
  withCollection 'cards', (cards) ->
    cards.find criteria, errorWrapper (cursor) ->
      cursor.each errorWrapper reducer

module.exports = {
  saveCard
  updateCard
  removeCard
  findCards
}
