$ = require 'jquery'

class Character
  constructor: (@display, @html, @start) ->

  equals: (other) ->
    return @display == other.display and @html == other.html and @start == other.start

  is_start: () ->
    return @start? and @start

  is_html: () ->
    return (not @display? or not @display.length) and @html? and @html.length > 0

module.exports =
  Character: Character