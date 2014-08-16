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
      if element.selectionStart
        element.focus()
        element.setSelectionRange index, index
      else
        element.focus()

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

  process_op: (operation_list, string) ->
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
      # alert "Keypress: '" + k "'"
      if k
        cursor = utils.get_cursor this
        woot_character = woot.generate_insert(
          cursor, k, woot_state.participant_name, woot_state.sequence_number, woot_state.string)
        woot.integrate_insert woot_state.string, woot_character
        utils.add_applied_op woot_state.applied_ops, constants.INSERT_OPERATION, woot_character
        woot_state.sequence_number += 1
        element.val woot.value(woot_state.string)
        utils.set_cursor this, cursor + 1

        utils.send_op(woot_state.events_ref, constants.INSERT_OPERATION, woot_character)
        event.stopPropagation()
        return false

  bind_keydown: (element, extended, woot_state) ->
    utils = this
    element.keydown (event) ->
      if event.keyCode == 8
        # This is the case for backspace
        cursor = utils.get_cursor this
        woot_character = woot.generate_delete cursor - 1, woot_state.string
        if woot_character
          # We have a visible character to delete
          woot.integrate_delete woot_state.string, woot_character
          utils.add_applied_op(
            woot_state.applied_ops, constants.DELETE_OPERATION, woot_character)
          woot_state.sequence_number += 1
          element.val woot.value(woot_state.string)
          utils.set_cursor this, cursor - 1

          utils.send_op woot_state.events_ref, constants.DELETE_OPERATION, woot_character
          event.stopPropagation()
          return false
