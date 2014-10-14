assert = require 'assert'
{Id} = require '../../../public/javascripts/lib/fraction_array/id.coffee'
{FractionArray} = require '../../../public/javascripts/lib/fraction_array/fraction_array.coffee'

class TestCharacter
  constructor: (@string) ->

  to_string: () ->
    return @string

describe "fraction_array_tests", () ->

  describe "test insert", () ->
    it "should be able to insert things", () ->
      participant_id = "participant_id"
      array = new FractionArray()
      array.insert 0, new TestCharacter("b"), participant_id
      array.insert 1, new TestCharacter("c"), participant_id
      array.insert 0, new TestCharacter("a"), participant_id

      assert.equal array.to_string(), 'abc'

    it "should be able to insert things by id", () ->
      participant_id = "participant_id"
      array = new FractionArray()
      array.insert_id new Id('B|C|' + participant_id), new TestCharacter("b")
      array.insert_id new Id('D|E|' + participant_id), new TestCharacter("c")
      array.insert_id new Id('B|E|' + participant_id), new TestCharacter("a")

      assert.equal array.to_string(), 'abc'

  describe "test remove", () ->
    it "should be able to remove elements", () ->
      participant_id = "participant_id"
      array = new FractionArray()
      array.insert 0, new TestCharacter("c"), participant_id
      array.insert 0, new TestCharacter("b"), participant_id
      array.insert 0, new TestCharacter("a"), participant_id

      assert.equal array.to_string(), 'abc'

      array.remove 2
      assert.equal array.to_string(), 'ab'

      array.insert 2, new TestCharacter("d"), participant_id
      assert.equal array.to_string(), 'abd'
      array.remove 0
      array.remove 1
      assert.equal array.to_string(), 'b'

      array.remove 0
      assert.equal array.to_string(), ''

    it "should be able to remove things by id", () ->
      participant_id = "participant_id"
      one_half = new Id('B|C|' + participant_id)
      three_fourths = new Id('D|E|' + participant_id)
      one_fourth = new Id('B|E|' + participant_id)

      array = new FractionArray()
      array.insert_id one_half, new TestCharacter("b")
      array.insert_id three_fourths, new TestCharacter("c")
      array.insert_id one_fourth, new TestCharacter("a")

      assert.equal array.to_string(), 'abc'

      array.remove_id three_fourths
      assert.equal array.to_string(), 'ab'

      array.insert_id three_fourths, new TestCharacter("d"), participant_id
      assert.equal array.to_string(), 'abd'
      array.remove_id one_fourth
      array.remove_id three_fourths
      assert.equal array.to_string(), 'b'

      array.remove_id one_half
      assert.equal array.to_string(), ''
