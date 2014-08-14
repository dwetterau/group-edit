define
  initialize_string: () ->
    begin_character =
      id:
        name: ''
        number: 0
      visible: false
      value: ''
    end_character =
      id:
        name: ''
        number: 1
      visible: false
      value: ''
    return [begin_character, end_character]

  length: (string) ->
    return string.length

  get_character: (string, index) ->
    return string[index]

  compare_id: (id1, id2) ->
    if id1.name == id2.name
      return id1.number - id2.number
    else if id1.name < id2.name
      return -1
    else if id1.name > id2.name
      return 1
    else
      throw Error('Programming Error in compare_id')

  get_position: (string, target_id) ->
    for character, index in string
      if character.id.name == target_id.name and character.id.number == target_id.number
        return index
    return -1

  insert: (string, character, index) ->
    string.splice(index, 0, character)

  set_visible: (string, index, visible) ->
    string[index].visible = visible

  sub_sequence: (string, start_index, end_index) ->
    return (c.id for c in string.slice(start_index + 1, end_index))

  contains: (string, target) ->
    # TODO(david): Make this not do a linear scan
    return this.get_position string, target.id != -1

  contains_by_id: (string, target_id) ->
    # TODO(david): Make this a fast lookup
    return this.get_position string, target_id != -1

  value: (string) ->
    visible_string = ''
    for character in string
      if character.visible
        visible_string += character.value

    return visible_string

  ith_visible: (string, index) ->
    index_seen = -1
    for character in string
      if character.visible
        index_seen += 1
      if index_seen == index
        return character
    return null

  generate_insert: (index, visible_string, participant_name, sequence_number, string) ->
    before_character = this.ith_visible(string, index - 1)
    after_character = this.ith_visible(string, index)
    if not before_character
      before_character = string[0]
    if not after_character
      after_character = string[this.length(string) - 1]
    woot_character =
      id:
        number: sequence_number
        name: participant_name
      visible: true
      value: visible_string
      before_id: before_character.id
      after_id: after_character.id

    return woot_character

  generate_delete: (index, string) ->
    return this.ith_visible(string, index)

  is_executable: (operation, character, string) ->
    if operation == 'delete'
      return this.contains string, character
    else if operation == 'insert'
      return this.contains_by_id(string, character.before_id) and
          this.contains_by_id(string, character.after_id)
    else
      throw Error("Unknown operation type")

  integrate_delete: (string, character) ->
    index = this.get_position(string, character.id)
    if index == -1
      throw Error("Delete preconditions not met")
    this.set_visible string, index, false

  integrate_insert: (string, character) ->
    this.integrate_insert_helper string, character, character.before_id, character.after_id

  integrate_insert_helper: (string, character, before_id, after_id) ->
    # Get the before and after character indices
    before_index = this.get_position string, before_id
    after_index = this.get_position string, after_id

    if before_index == -1 or after_index == -1
      throw Error("Insert preconditions not met")

    sub_sequence = this.sub_sequence(string, before_index, after_index)
    if sub_sequence.length == 0
      this.insert string, character, after_index
    else
      # Add on the before and after indices again
      sub_sequence.unshift before_id
      sub_sequence.push after_id
      i = 1
      while i < sub_sequence.length - 1 and this.compare_id(sub_sequence[i], character.id) < 0
        i += 1
      this.integrate_insert_helper string, character, sub_sequence[i - 1], sub_sequence[i]
