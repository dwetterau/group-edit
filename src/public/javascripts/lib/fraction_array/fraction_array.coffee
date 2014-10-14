{Id} = require './id.coffee'
{SkipList} = require 'node-skiplist'

class FractionArray
  constructor: () ->
    @map = {}
    @skiplist = new SkipList()

    # Insert the boundary marker nodes
    @skiplist.insert new Id("A|B|null")
    @skiplist.insert new Id("B|B|null")

  insert: (index, character, participant_id) ->
    # First generate the id
    # We want to insert before index + 1 and right after index
    # (because of the off by 1 with the boundary node)
    before = @skiplist.rank index
    after = @skiplist.rank index + 1

    new_id = new Id()
    new_id.from_neighbors before, after, participant_id

    @map[new_id.to_string()] = character
    @skiplist.insert new_id

  insert_id: (id, character) ->
    @map[id.to_string()] = character
    @skiplist.insert id

  remove: (index) ->
    # Note we add one here because of the dummy boundary node
    id = @skiplist.rank index + 1
    @skiplist.remove index + 1
    delete @map[id]

  remove_id: (id) ->
    index = @skiplist.find id
    @skiplist.remove index
    delete @map[id]

  to_string: () ->
    result = []
    list = @skiplist.to_list()
    for id, index in list
      # We need to skip the first and last element
      if index == 0
        continue
      if index == list.length - 1
        continue
      result.push @map[id.to_string()].to_string()
    return result.join ''

module.exports =
  FractionArray: FractionArray