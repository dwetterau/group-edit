woot = require './woot.coffee'
constants = require './constants.coffee'
{Character} = require './meta_string/character.coffee'

module.exports =
  get_cursor: (element) ->
    # Gets the index of the cursor and the text node it's in
    if not window.getSelection or window.getSelection().rangeCount <= 0
      return { index: 0, parent: undefined }
    range = window.getSelection().getRangeAt(0)
    return {
      index: range.endOffset
      parent: range.commonAncestorContainer
    }

  set_cursor: (element, index) ->
    if document.createRange()
      range = document.createRange()
      selection = window.getSelection()
      range.setStart(element, index)
      range.collapse(true)
      selection.removeAllRanges()
      selection.addRange(range)
    else
      element.focus()

  get_cursor_state: (element, string) ->
    # Traverse down the dom and record what elements we go through to
    cursor_object = this.get_cursor element
    enters = 0
    exits = 0

    depth_search = (node) ->
      inc = if node.nodeType == constants.TEXT_NODE > 0 then 0 else 1
      enters += inc
      if node == cursor_object.parent
        return true
      for child in node.childNodes
        if depth_search child
          return true
      exits += inc
      return false
    depth_search element

    # Enters starts at 1 for the original node.
    seen_enters = 0
    seen_exits = 0
    start_index = 0
    for woot_character, index in string
      character = new Character()
      character.from_json woot_character.value
      if character.is_html()
        if character.is_start()
          seen_enters++
        else
          seen_exits++
      else
        if seen_enters == enters and seen_exits == exits
          while start_index != cursor_object.index and index < string.length
            if string[index].visible
              start_index++
            index++
          if start_index == cursor_object.index
            before_cursor_character = string[index]
            after_cursor_character = string[index - 1]
          break

    if not after_cursor_character
      after_cursor_character = string[0]
    if not before_cursor_character
      before_cursor_character = string[string.length - 1]
    cursor_state =
      character:
        id:
          name: ''
          number: 2 # This is 2 because begin and end character are 0 and 1
        visible: false
        value: {}
      before_id: before_cursor_character.id
      after_id: after_cursor_character.id

    if cursor_object.parent?
      debugger

    return cursor_state

  set_cursor_state: (element, string, cursor_state) ->
    string_index = woot.determine_insert_position(
      string, cursor_state.character, cursor_state.before_id, cursor_state.after_id)
    new_index = woot.string_index_to_ith string, string_index, true
    stack = [element]
    node = undefined
    total_length = 0
    debugger
    while stack.length
      node = stack.pop()
      length = 0
      if node.tagName.toLowerCase() of constants.DOM_TAGS
        length += constants.DOM_TAGS[node.tagName.toLowerCase()].length
      if node.nodeType == constants.TEXT_NODE
        length += $(node).text().length
      if total_length + length >= new_index
        break
      total_length += length
      for n in (n for n in node.childNodes).reverse()
        stack.push n

    this.set_cursor node, new_index - total_length

  get_op_key: (operation, character) ->
    return [operation, character.id.name, character.id.number].join('|')

  add_applied_op: (applied_ops, operation, character) ->
    key = this.get_op_key operation, character
    applied_ops[key] = true

  check_applied_op: (applied_ops, operation, character) ->
    key = this.get_op_key operation, character
    return applied_ops[key]

  send_op: (events_ref, operation, character) ->
    events_ref.push
      operation: operation
      character: character
      is_bulk: false

  send_bulk_op: (events_ref, operation, character_list) ->
    events_ref.push
      operation: operation
      character_list: character_list
      is_bulk: true

  process_op: (operation_list, string, applied_ops) ->
    # If no operations to process, return
    if not operation_list.length
      return false

    # Try to execute the operation
    operation_object = operation_list.pop()
    result = woot.execute_operation(
      operation_object.operation, operation_object.character, string)

    if not result
      # If we failed to apply the operation, add it back to the front of the list
      operation_list.unshift operation_object
      return false
    else
      this.add_applied_op applied_ops, operation_object.operation, operation_object.character
      return true

  process_bulk_insert: (character_list, start_index, woot_state) ->
    insert_characters = []
    for c, index in character_list
      woot_character = woot.generate_insert(
        start_index + index,
        c,
        woot_state.participant_name,
        woot_state.sequence_number,
        woot_state.string
      )
      this.execute_operation(
        constants.INSERT_OPERATION, woot_character, woot_state
      )
      # We unshift here so that they get pushed on in reverse and applied
      # in the correct order (since they are applied through pops)
      insert_characters.unshift woot_character
    this.send_bulk_op woot_state.events_ref, constants.INSERT_OPERATION, insert_characters

  process_bulk_delete: (character_list, start_index, woot_state) ->
    delete_characters = []
    for character, index in character_list
      delete_characters.push woot.generate_delete start_index + index, woot_state.string
    for character in delete_characters
      this.execute_operation constants.DELETE_OPERATION, character, woot_state
    this.send_bulk_op woot_state.events_ref, constants.DELETE_OPERATION, delete_characters

  process_diff: (diff_array, woot_state) ->
    index = 0
    for diff_subarray in diff_array
      type = diff_subarray[0]
      character_list = diff_subarray[1]
      if type == 1
        @.process_bulk_insert character_list, index, woot_state
      else if type == -1
        @.process_bulk_delete character_list, index, woot_state
        index -= character_list.length
      index += character_list.length

  execute_operation: (operation, woot_character, woot_state) ->
    if operation == constants.DELETE_OPERATION
      woot.integrate_delete woot_state.string, woot_character
    else if operation == constants.INSERT_OPERATION
      woot.integrate_insert woot_state.string, woot_character
    else
      throw Error("Unknown operation")
    this.add_applied_op(
      woot_state.applied_ops, operation, woot_character)
    woot_state.sequence_number += 1

  character_list_to_string: (character_list) ->
    visible_string = ''
    for character in character_list
      visible_string += character.html

    return visible_string