define ['lib/constants', 'lib/woot'], (constants, woot) ->
  get_cursor: (element) ->
    if element.selectionStart
      return element.selectionStart
    else if document.selection
      element.focus()
      r = document.selection.createRange()
      if r == null
        return 0

      re = element.createTextRange()
      rc = re.duplicate()
      re.moveToBookmark r.getBookmark()
      rc.setEndPoint 'EndToStart', re
      return rc.text.length
    return 0

  set_cursor: (element, index) ->
    if element.createTextRange
      range = element.createTextRange()
      range.move 'character', index
      range.select()
    else
      if element.selectionStart?
        element.focus()
        element.setSelectionRange index, index
      else
        element.focus()

  get_cursor_state: (element, string) ->
    cursor_index = this.get_cursor element
    after_cursor_character = woot.ith_visible string, cursor_index - 1
    before_cursor_character = woot.ith_visible string, cursor_index
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
        value: ''
      before_id: before_cursor_character.id
      after_id: after_cursor_character.id

    return cursor_state

  set_cursor_state: (element, string, cursor_state) ->
    string_index = woot.determine_insert_position(
      string, cursor_state.character, cursor_state.before_id, cursor_state.after_id)
    new_index = woot.string_index_to_ith string, string_index
    this.set_cursor element, new_index + 1

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

  is_mobile: () ->
    try
      document.createEvent "TouchEvent"
      return true
    catch e
      return false

  bind_keypress: (element, woot_state) ->
    utils = this
    element.keypress (event) ->
      k = String.fromCharCode event.which
      if k
        cursor = utils.get_cursor this
        woot_character = woot.generate_insert(
          cursor, k, woot_state.participant_name, woot_state.sequence_number, woot_state.string)
        utils.execute_operation constants.DELETE_OPERATION, woot_character, woot_state, element
        utils.set_cursor this, cursor + 1

        utils.send_op(woot_state.events_ref, constants.INSERT_OPERATION, woot_character)
        event.stopPropagation()
        return false

  bind_keydown: (element, extended, woot_state) ->
    utils = this
    element.keydown (event) ->
      if event.keyCode == 8
        selection_delete = utils.check_and_delete_selection this, woot_state
        if selection_delete
          return
        # This is the case for backspace
        cursor = utils.get_cursor this
        woot_character = woot.generate_delete cursor - 1, woot_state.string
        if woot_character
          # We have a visible character to delete
          utils.execute_operation constants.DELETE_OPERATION, woot_character, woot_state, element
          utils.set_cursor this, cursor - 1

          utils.send_op woot_state.events_ref, constants.DELETE_OPERATION, woot_character

        event.stopPropagation()
        return false
      else
        console.log event.keyCode

  bind_paste: (element, woot_state) ->
    utils = this
    element.on 'paste', (event) ->
      text = (event.originalEvent || event).clipboardData.getData('text/plain')
      if not text.length
        return
      cursor_index = utils.get_cursor this
      insert_characters = []
      for c, index in text.split ''
        woot_character = woot.generate_insert(
          cursor_index + index,
          c,
          woot_state.participant_name,
          woot_state.sequence_number,
          woot_state.string
        )
        utils.execute_operation(
          constants.INSERT_OPERATION, woot_character, woot_state, element
        )
        # We unshift here so that they get pushed on in reverse and applied
        # in the correct order (since they are applied through pops)
        insert_characters.unshift woot_character
      utils.set_cursor this, cursor_index + text.length
      utils.send_bulk_op woot_state.events_ref, constants.INSERT_OPERATION, insert_characters

      event.stopPropagation()
      return false

  check_and_delete_selection: (element, woot_state) ->
    selection = utils.get_selection_range element
    if selection.text.length
      # We need to delete all of the selected text.
      delete_characters = []
      for i in [selection.start..selection.end - 1]
        delete_characters.push woot.generate_delete i, woot_state.string
      for character in delete_characters
        utils.execute_operation constants.DELETE_OPERATION, character, woot_state, element
      utils.set_cursor element, selection.start
      utils.send_bulk_op woot_state.events_ref, constants.DELETE_OPERATION, delete_characters
      return true
    return false

  execute_operation: (operation, woot_character, woot_state, element) ->
    if operation == constants.DELETE_OPERATION
      woot.integrate_delete woot_state.string, woot_character
    else if operation == constants.INSERT_OPERATION
      woot.integrate_insert woot_state.string, woot_character
    else
      throw Error("Unknown operation")
    this.add_applied_op(
      woot_state.applied_ops, operation, woot_character)
    woot_state.sequence_number += 1
    element.val woot.value(woot_state.string)

  get_selection_range: (element) ->
    output =
      start: -1
      end: -1
    if element.createTextRange
      range = document.selection.createRange().duplicate()
      range.moveEnd('character', element.value.length)
      if range.text == ''
        output.start = element.value.length
      else
        output.start = element.value.lastIndexOf range.text

      range = document.selection.createRange().duplicate()
      range.moveStart('character', -element.value.length)
      output.end = range.text.length
    else
      output.start = element.selectionStart
      output.end = element.selectionEnd

    output.text = element.value.substring(output.start, output.end)
    return output

