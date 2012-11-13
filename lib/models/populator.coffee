Child = null

class Populator
  constructor: (parent, child) ->
    Child = require "./#{child}"
    @children = "#{child}s"
    @fk = "#{parent}Id"

  populate: (callback) ->
    return undefined unless callback?
    (error, parents) =>
      return callback error, parents unless parents?
      if parents.length?
        @populateMany callback, parents
      else
        @populateOne callback, parents

  populateMany: (callback, parents) ->
    map = {}
    map[parent.id] = parent for parent in parents
    ids = ( parent.id for parent in parents )
    parent[@children] = [] for parent in parents
    query = {}
    query[@fk] = { $in: ids }
    Child.find query, (error, children) =>
      for child in children
        do (child) =>
          parent = map[child[@fk]]
          parent[@children].push child
      callback error, parents

  populateOne: (callback, parent) ->
    query = {}
    query[@fk] = parent.id
    Child.find query, (error, children) =>
      parent[@children] = children
      callback error, parent

module.exports = Populator
