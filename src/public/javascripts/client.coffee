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
  pending_operation_list = []
  initialized = false

  # On page load, load the list of all operations, perform them once.
  events_ref.once 'value', (data) ->
    all_objects = data.val()
    for key, operation_object of all_objects
      operation_list.push operation_object
      utils.add_applied_op applied_ops, operation_object.operation, operation_object.character
    while operation_list.length > 0
      utils.process_op operation_list, string
    element = $('#input')
    string_representation = woot.value string
    element.val string_representation
    console.log string_representation
    utils.set_cursor(element, string_representation.length - 1)

    # We have to start putting new operations in the real list before we move
    # the pending ones over.
    initialized = true
    for operation_object in pending_operation_list
      operation = operation_object.operation
      character = operation_object.character
      # Only move over pending operations that haven't been locally applied
      if not utils.check_applied_op applied_ops, operation, character
        operation_list.push operation_object

  # On a new event, we need to try to perform it, and if that fails, add to pool
  events_ref.on 'child_added', (snapshot, previous_child) ->
    operation_object = snapshot.val()
    operation = operation_object.operation
    character = operation_object.character

    # Ignore locally applied events
    if utils.check_applied_op applied_ops, operation, character
      return

    # TODO(david): Investigate if it's faster to unshift or push here
    if initialized
      operation_list.push operation_object
      apply_operations()
    else
      pending_operation_list.push operation_object

  $('#input').keypress((event) ->
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

  apply_operations = () ->
    # Try to process all of the pending operations
    iterations = operation_list.length
    should_update = false
    while iterations > 0
      iterations--
      need_to_update_input = utils.process_op operation_list, string
      should_update |= need_to_update_input
    if should_update
      # We need to update the text content with the new value and
      # move the cursor back to where it was...
      element = $('#input')
      element.val woot.value string
      # TODO(david): Eliminate cursor creep, you losing your spot because someone else typed
      # something earlier in the string than where you were. Basically we need to figure out
      # when to move the cursor one over or when to leave it where it is...
      # idea!: leverage WOOT to store the cursor position also.
      utils.set_cursor(element, utils.get_cursor element)

  setInterval apply_operations, 100
