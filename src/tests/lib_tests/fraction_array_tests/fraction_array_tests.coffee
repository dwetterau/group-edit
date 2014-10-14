assert = require 'assert'
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