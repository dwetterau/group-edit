$ = require('jquery')
constants = require('../constants.coffee')
{Character} = require('./character.coffee')

module.exports =
  to_character_list: (element) ->
    character_list = @._node_to_character_list(element)
    try
      @.to_html(character_list)
    catch e
      console.log "there was an exception"
      console.log e
    return character_list

  to_html: (character_list) ->
    character_list = @._compress_display_character_list character_list
    root = $(constants.DOM_TAGS['div'].html)
    node_stack = [root]
    for character in character_list
      parent = node_stack[node_stack.length - 1]
      if character.is_html()
        if character.is_start()
          node_stack.push $(character.html)
        else
          element = node_stack.pop()
          # Need to reset the parent because we popped one off.
          if node_stack.length == 0
            # This happens because the dom doesn't clean up fast enough. It should be followed
            # up immediately with a correct call.
            return
          parent = node_stack[node_stack.length - 1]
          parent.append element
      else
        parent.text character.display

    # If the parsing was correct, only the root should be left on the stack
    if not node_stack.length == 1
      throw new Error 'Issue parsing character stack'
    root = node_stack.pop()
    root_html_with_div = root.html()
    return root_html_with_div.substring(5, root_html_with_div.length - 6)

  _node_to_character_list: (node) ->
    character_list = []
    if node.hasChildNodes()
      {open_tag, close_tag} = @._node_to_tags node
      character_list.push open_tag
      children = node.childNodes
      for child in children
        character_list = character_list.concat @._node_to_character_list child
      character_list.push close_tag
    else
      text = $(node).text()
      if text.length
        character_list = @._string_to_character_list text
      else if node.tagName.toLowerCase() of constants.DOM_TAGS
        tag = constants.DOM_TAGS[node.tagName.toLowerCase()].html
        character_list = [
          new Character('', tag, true)
          new Character('', tag, false)
        ]
      else
        throw new Error "Could not make character of node"
    return character_list

  _compress_display_character_list: (character_list) ->
    # Compress all adjacent text characters together
    new_character_list = []
    current_string = ''
    for character in character_list
      if character.is_html()
        if current_string.length
          new_character_list.push new Character(current_string)
          current_string = ''
        new_character_list.push character
      else
        current_string += character.display
    if current_string.length
      new_character_list.push new Character(current_string)
    return new_character_list

  _node_to_tags: (node) ->
    tag = constants.DOM_TAGS[node.tagName.toLowerCase()]
    if tag?
      return {
        open_tag: new Character('', tag.html, true)
        close_tag: new Character('', tag.html, false)
      }
    else
      return {}

  _string_to_character_list: (string) ->
    character_list = []
    for i in [0...string.length]
      character_list.push(new Character(string.charAt(i)))

    return character_list

