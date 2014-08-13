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

  get_position: (string, target) ->
    for character, index in string
      if character.id.name == target.id.name and character.id.number == target.id.number
       return index
    return -1

  insert: (string, character, index) ->
    string.splice(index, 0, character)

  sub_sequence: (string, start_index, end_index) ->
    return string.slice(start_index + 1, end_index)

  contains: (string, target) ->
    # TODO(david): Make this not do a linear scan
    return this.get_position string, target != -1

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
    before_character = this.ith_visible(string, index)
    after_character = this.ith_visible(string, index + 1)
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