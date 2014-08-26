$ = require 'jquery'

class Character
  constructor: (@display, @html) ->

  equals: (other) ->
    return @display == other.display and @html == other.html

  toJQuery: () ->
    return $(@html)

module.exports =
  Character: Character