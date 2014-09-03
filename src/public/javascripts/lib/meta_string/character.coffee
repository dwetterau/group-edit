$ = require 'jquery'

class Character
  constructor: (display, html, start) ->
    @display = if display? then display else ''
    @html = if html? then html else ''
    @start = if start? then start else false

  equals: (other) ->
    return @display == other.display and @html == other.html and @start == other.start

  is_start: () ->
    return @start? and @start

  is_html: () ->
    return (not @display? or not @display.length) and @html? and @html.length > 0

  to_json: () ->
    return {
      display: @display,
      html: @html,
      start: @start
    }

  from_json: (json) ->
    @display = json.display
    @html = json.html
    @start = json.start

module.exports =
  Character: Character