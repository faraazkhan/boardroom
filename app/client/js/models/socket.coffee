#= require './../views/namespace'

class boardroom.models.Socket extends Backbone.Model
  initialize: (attributes) ->
    url = "/boardNamespace/#{@get('board').get('name')}"
    @socket = io.connect url
