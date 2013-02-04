@boardroom =
  models: {}
  views: {}

removeRefs = (atts) ->
  return null unless atts
  data = {}
  for own key,val of atts
    data[key]=val unless val instanceof Backbone.Model or val instanceof Backbone.Collection or val instanceof Backbone.View
  data

Backbone.sync = (method, model, options)->
  className = model.constructor.name
  eventType = "#{className}.#{method}"

  payload = {}
  payload.id = model.id if model?.id?
  payload.cid = model.cid if model?.cid?

  switch method # set payload.data
    when 'create', 'update'  then data = model.attributes
    else data = options?.data if options?.data?
  payload.data = removeRefs data 

  console.log 'syncing', eventType, payload
  boardroom.socket?.emit eventType, payload
