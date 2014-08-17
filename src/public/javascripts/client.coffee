require ['lib/constants', 'lib/woot', 'lib/utils'], (constants, woot, utils) ->
  firebase = new Firebase(constants.FIREBASE)

  test_room_ref = firebase.child(constants.TEST_CHILD)

  events_ref = test_room_ref.child(constants.EVENTS_CHILD)

  participants_ref = test_room_ref.child(constants.PARTICIPANTS_CHILD)


  # Get our unique id from pushing onto the participants ref
  participant_name = participants_ref.push {'new_participant': new Date()}
  participant_name = participant_name.name()
  console.log "Participant name:", participant_name

  woot_state =
    applied_ops: {}
    events_ref: events_ref
    participant_name: participant_name
    sequence_number: 0
    string: woot.initialize_string()

  operation_list = []
  pending_operation_list = []
  initialized = false

  # On page load, load the list of all operations, perform them once.
  woot_state.events_ref.once 'value', (data) ->
    all_objects = data.val()
    for key, operation_object of all_objects
      unpack_and_push_operation operation_object, operation_list
    while operation_list.length > 0
      utils.process_op operation_list, woot_state.string, woot_state.applied_ops
    element = $('#input')
    string_representation = woot.value woot_state.string
    element.val string_representation
    utils.set_cursor(element, string_representation.length - 1)

    # We have to start putting new operations in the real list before we move
    # the pending ones over.
    initialized = true
    for operation_object in pending_operation_list
      operation = operation_object.operation
      character = operation_object.character
      # Only move over pending operations that haven't been locally applied
      if not utils.check_applied_op woot_state.applied_ops, operation, character
        operation_list.push operation_object

  push_operation = (operation_object, list) ->
    operation = operation_object.operation
    character = operation_object.character

    # Ignore locally applied events
    if utils.check_applied_op woot_state.applied_ops, operation, character
      return

    # TODO(david): Investigate if it's faster to unshift or push here
    list.push operation_object

  unpack_and_push_operation = (operation_object, list) ->
    if operation_object.is_bulk
      # Unpack the operation object into many operations
      for character in operation_object.character_list
        new_operation_object =
          operation: operation_object.operation
          character: character
        push_operation new_operation_object, list
    else
      push_operation operation_object, list

  # On a new event, we need to try to perform it, and if that fails, add to pool
  woot_state.events_ref.on 'child_added', (snapshot, previous_child) ->
    operation_object = snapshot.val()

    if initialized
      unpack_and_push_operation operation_object, operation_list
      apply_operations()
    else
      unpack_and_push_operation operation_object, pending_operation_list

  input_element = $('#input')
  keydown_extended = true
  if not utils.is_mobile()
    console.log "not mobile"
    utils.bind_keypress input_element, woot_state
    keydown_extended = false
  else
    console.log "is mobile"

  utils.bind_keydown input_element, keydown_extended, woot_state

  apply_operations = () ->
    # Try to process all of the pending operations
    iterations = operation_list.length
    should_update = false
    while iterations > 0
      iterations--
      need_to_update_input = utils.process_op(
        operation_list, woot_state.string, woot_state.applied_ops)
      should_update |= need_to_update_input
    if should_update
      # We need to update the text content with the new value and
      # move the cursor back to where it was...
      element = $('#input')
      element.val woot.value woot_state.string
      # TODO(david): Eliminate cursor creep, you losing your spot because someone else typed
      # something earlier in the string than where you were. Basically we need to figure out
      # when to move the cursor one over or when to leave it where it is...
      # idea!: leverage WOOT to store the cursor position also.
      utils.set_cursor(element, utils.get_cursor element)

  setInterval apply_operations, 100
