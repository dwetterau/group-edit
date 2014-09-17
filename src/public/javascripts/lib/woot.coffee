constants = require './constants.coffee'
{Character} = require './meta_string/character.coffee'

module.exports =
  initialize_string: () ->
    begin_character =
      id:
        name: ''
        number: 0
      visible: false
      value: {}
    end_character =
      id:
        name: ''
        number: 1
      visible: false
      value: {}
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
    return this.get_position(string, target.id) != -1

  contains_by_id: (string, target_id) ->
    # TODO(david): Make this a fast lookup
    return this.get_position(string, target_id) != -1

  value: (string) ->
    meta_string = []
    for character in string
      if character.visible
        meta_character = new Character()
        meta_character.from_json character.value
        meta_string.push meta_character

    return meta_string

  ith_visible: (string, index) ->
    index_seen = -1
    for character in string
      if character.visible
        index_seen += 1
      if index_seen == index
        return character
    return null

  string_index_to_ith: (string, string_index, no_html) ->
    index_seen = -1
    string_index_seen = -1
    for character in string
      string_index_seen += 1
      if character.visible
        if no_html
          c = new Character()
          c.from_json(character.value)
          if c.is_html() and (
            constants.DOM_TAGS[c.html.slice(1, c.html.length - 1)].length == 0 or not c.is_start())
            index_seen -= 1
        index_seen += 1
      if string_index == string_index_seen
        return index_seen
    return index_seen

  generate_insert: (index, meta_character, participant_name, sequence_number, string) ->
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
      value: meta_character.to_json()
      before_id: before_character.id
      after_id: after_character.id

    return woot_character

  generate_delete: (index, string) ->
    return this.ith_visible(string, index)

  execute_operation: (operation, character, string) ->
    if not this.is_executable operation, character, string
      return false

    if operation == constants.DELETE_OPERATION
      this.integrate_delete string, character
    else if operation == constants.INSERT_OPERATION
      this.integrate_insert string, character
    else
      throw Error("Unknown operation type")

    return true

  is_executable: (operation, character, string) ->
    if operation == constants.DELETE_OPERATION
      return this.contains string, character
    else if operation == constants.INSERT_OPERATION
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
    insert_position = this.determine_insert_position(
      string, character, character.before_id, character.after_id)
    this.insert string, character, insert_position

  determine_insert_position: (string, character, before_id, after_id) ->
    # Get the before and after character indices
    before_index = this.get_position string, before_id
    after_index = this.get_position string, after_id

    if before_index == -1 or after_index == -1
      throw Error("Insert preconditions not met")

    sub_sequence = this.sub_sequence(string, before_index, after_index)
    if sub_sequence.length == 0
      return after_index
    else
      # Add on the before and after indices again
      sub_sequence.unshift before_id
      sub_sequence.push after_id
      i = 1
      while i < sub_sequence.length - 1 and this.compare_id(sub_sequence[i], character.id) < 0
        i += 1
      this.determine_insert_position string, character, sub_sequence[i - 1], sub_sequence[i]
