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

  # On a new event, we need to try to perform it, and if that fails, add to pool
  events_ref.on 'child_added', (snapshot, previous_child) ->
    # TODO(david): Investigate if we can leverage the child's name to serialize all operations.
    # Seems like this approach would have trouble with eventual offline editing
    console.log "Got a new event:", snapshot.val()

  $('#input').keypress (event) ->
    k = String.fromCharCode event.which
    console.log "key pressed:", k
    if k
      cursor = utils.get_cursor this
      console.log "cursor index=", cursor
      woot_character = woot.generate_insert cursor, k, participant_name, sequence_number, string
      woot.integrate_insert string, woot_character
      events_ref.push
        woot_character: woot_character
      sequence_number += 1
      @value = woot.value(string)
      event.stopPropagation()
      return false
