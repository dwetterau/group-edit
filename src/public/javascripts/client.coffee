require ['lib/constants', 'lib/woot', 'lib/utils'], (constants, woot, utils) ->
  firebase = new Firebase(constants.FIREBASE)

  test_room_ref = firebase.child(constants.TEST_CHILD)

  events_ref = test_room_ref.child(constants.EVENTS_CHILD)

  participants_ref = test_room_ref.child(constants.PARTICIPANTS_CHILD)

  sequence_number = 0

  # Get our unique id from pushing onto the participants ref
  participant_name = participants_ref.push {'new': new Date()}
  participant_name = participant_name.name()

  # On a new event, we need to try to perform it, and if that fails, add to pool
  events_ref.on 'child_added', (snapshot, previous_child) ->
    # TODO(david): Investigate if we can leverage the child's name to serialize all operations.
    # Seems like this approach would have trouble with eventual offline editing

  $('#input').keypress (event) ->
    k = String.fromCharCode event.which
    console.log "key pressed:", k
    if k
      cursor = utils.get_cursor this
      console.log "cursor index=", cursor
      console.log "content=", @value
      if cursor > 0
        console.log 'character before:', @value.charAt cursor - 1
      if cursor <= @value.length - 1
        console.log 'character after:', @value.charAt cursor
