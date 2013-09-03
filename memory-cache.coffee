_ = require 'lodash'

cache = {}

module.exports.set = (name, data, expires) ->
  clearTimeout cache[name].timer if _.has(cache, name)

  clear = () -> delete cache[name]

  cache[name] = {
    data : data,
    timer : setTimeout clear, expires
  }
  true

module.exports.get = (name) ->
  if _.has(cache, name) then cache[name].data else null