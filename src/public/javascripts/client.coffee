Character = require('./lib/meta_string/character.coffee').Character
constants = require './lib/constants.coffee'
diff = require('./lib/diff/diff.coffee')
meta_string = require('./lib/meta_string/meta_string.coffee')
utils = require './lib/utils.coffee'
woot = require './lib/woot.coffee'

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
old_value = ''

# On page load, load the list of all operations, perform them once.
woot_state.events_ref.once 'value', (data) ->
  all_objects = data.val()
  for key, operation_object of all_objects
    unpack_and_push_operation operation_object, operation_list
  console.log "beginning to process", operation_list.length, "operation(s)."
  start = new Date()
  while operation_list.length > 0
    utils.process_op operation_list, woot_state.string, woot_state.applied_ops
  console.log "Initial processing took", (new Date() - start), "ms."

  element = $('#input')
  character_list = woot.value woot_state.string
  element.html(meta_string.to_html character_list)
  old_value = character_list
  # FIXME: We need a new way of getting / setting the cursor!
  #utils.set_cursor(element.get(0), string_representation.length)

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

onchange_callback = (event) ->
  before = old_value
  after = meta_string.to_character_list this

  utils.process_diff diff.diff(before, after), woot_state
  old_value = after

$('#input').bind 'input propertychange', onchange_callback

apply_operations = () ->
  # Store the cursor information before we do any operations
  element = $('#input')
  # FIXME we need a new way of getting the cursor state
  #before_cursor_state = utils.get_cursor_state element.get(0), woot_state.string
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
    new_value = woot.value woot_state.string
    # Update our old_value first so we don't fire off new diffs
    old_value = new_value
    element.html meta_string.to_html new_value

    # FIXME we need a new way of setting the cursor state
    # utils.set_cursor_state element.get(0), woot_state.string, before_cursor_state

setInterval apply_operations, 100
