class boardroom.models.Model extends Backbone.Model
  idAttribute: "_id"

  set: (attributes, options)->
    Backbone.Model::set.apply(@, arguments)

    data = attributes # assume a hash of attributes is passed
    if 'string' is $.type(attributes) # convert single key, value pair to a hash
      data = {}
      data[attributes] = options
    Backbone.sync 'update', @, { data }
