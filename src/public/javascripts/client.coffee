require ['lib/constants', 'lib/woot', 'lib/utils'], (constants, woot, utils) ->
  firebase = new Firebase(constants.FIREBASE)

  test_room_ref = firebase.child(constants.TEST_CHILD)

  events_ref = test_room_ref.child(constants.EVENTS_CHILD)

  participants_ref = test_room_ref.child(constants.PARTICIPANTS_CHILD)

  sequence_number = 0

  # Get our unique id from pushing onto the participants ref
  participant_name = participants_ref.push {'new_participant': new Date()}
  participant_name = participant_name.name()
  console.log "Participant name:", participant_name

  string = woot.initialize_string()
  applied_ops = {}
  operation_list = []

  # On a new event, we need to try to perform it, and if that fails, add to pool
  events_ref.on 'child_added', (snapshot, previous_child) ->
    operation_object = snapshot.val()
    operation = operation_object.operation
    character = operation_object.character

    # Ignore locally applied events
    if utils.check_applied_op applied_ops, operation, character
      return

    # TODO(david): Investigate if it's faster to unshift or push here
    operation_list.push operation_object

  $('#input').keypress((event) ->
    console.log event.keyCode
    k = String.fromCharCode event.which
    if k
      cursor = utils.get_cursor this
      woot_character = woot.generate_insert cursor, k, participant_name, sequence_number, string
      woot.integrate_insert string, woot_character
      utils.add_applied_op applied_ops, constants.INSERT_OPERATION, woot_character
      sequence_number += 1
      @value = woot.value(string)
      utils.set_cursor this, cursor + 1

      utils.send_op(events_ref, constants.INSERT_OPERATION, woot_character)
      event.stopPropagation()
      return false

  ).keydown (event) ->
    if event.keyCode == 8
      # This is the case for backspace
      cursor = utils.get_cursor this
      woot_character = woot.generate_delete cursor - 1, string
      if woot_character
        # We have a visible character to delete
        woot.integrate_delete string, woot_character
        utils.add_applied_op applied_ops, constants.DELETE_OPERATION, woot_character
        sequence_number += 1
        @value = woot.value(string)
        utils.set_cursor this, cursor - 1

        utils.send_op events_ref, constants.DELETE_OPERATION, woot_character
        event.stopPropagation()
        return false

  setInterval () ->
    need_to_update_input = utils.process_op operation_list, string
    if need_to_update_input
      # We need to update the text content with the new value and
      # move the cursor back to where it was...
      element = $('#input')
      element.val woot.value string
      # TODO(david): Eliminate cursor creep, you losing your spot because someone else typed
      # something earlier in the string than where you were. Basically we need to figure out
      # when to move the cursor one over or when to leave it where it is...
      utils.set_cursor(element, utils.get_cursor element)
  , 100
