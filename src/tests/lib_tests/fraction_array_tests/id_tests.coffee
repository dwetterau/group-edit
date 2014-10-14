assert = require 'assert'
{Id} = require '../../../public/javascripts/lib/fraction_array/id.coffee'

class TestCharacter
  constructor: (@string) ->

  to_string: () ->
    return @string

describe "id_tests", () ->

  describe "test constructor", () ->
    it "should contruct empty ids correctly", () ->
      empty_id = new Id()
      assert empty_id.numerator == ''
      assert empty_id.denominator == ''
      assert empty_id.participant_id == ''

    it "should construct full ids correctly", () ->
      full_id = new Id("numerator|denominator|participant_id")
      assert full_id.numerator == "numerator"
      assert full_id.denominator == "denominator"
      assert full_id.participant_id == "participant_id"

  describe "test compare", () ->
    it "should compare ids to 0 correctly", () ->
      zero = new Id('A|B|id')
      one_half = new Id('B|C|id')
      one = new Id('B|B|id')

      assert zero.compare(one_half) < 0
      assert one_half.compare(zero) > 0

      assert zero.compare(zero) == 0

      assert zero.compare(one) < 0
      assert one.compare(zero) > 0

    it "should compare other values correctly", () ->
      one_fourth = new Id('C|I|id')
      one_half = new Id('C|E|id')
      one_eighth = new Id('B|I|id')
      one = new Id('C|C|id')

      assert one.compare(one) == 0
      assert one_eighth.compare(one_eighth) == 0
      assert one_fourth.compare(one_fourth) == 0
      assert one_half.compare(one_half) == 0

      assert one_eighth.compare(one_fourth) < 0
      assert one_fourth.compare(one_half) < 0
      assert one_half.compare(one) < 0

      assert one_fourth.compare(one_eighth) > 0
      assert one_half.compare(one_fourth) > 0
      assert one.compare(one_half) > 0

      assert one_eighth.compare(one) < 0
      assert one_fourth.compare(one) < 0
      assert one_half.compare(one) < 0

  describe "test reduce", () ->
    it "should not reduce irreducible fractions", () ->
      one = new Id('B|B|id')
      three_fourths = new Id('D|E|id')
      one_half = new Id('B|C|id')
      one_fourth = new Id('B|E|id')
      one_eighth = new Id('B|I|id')

      one_copy = one.copy()
      three_fourths_copy = three_fourths.copy()
      one_half_copy = one_half.copy()
      one_fourth_copy = one_fourth.copy()
      one_eighth_copy = one_eighth.copy()

      one.reduce()
      three_fourths.reduce()
      one_half.reduce()
      one_fourth.reduce()
      one_eighth.reduce()

      assert one_copy.compare(one) == 0
      assert three_fourths_copy.compare(three_fourths) == 0
      assert one_half_copy.compare(one_half) == 0
      assert one_fourth_copy.compare(one_fourth) == 0
      assert one_eighth_copy.compare(one_eighth) == 0

    it "should reduce reducable fractions", () ->
      six_eights = new Id('G|I|id')
      six_eights.reduce()
      three_fourths = new Id('D|E|id')

      two_fourths = new Id('C|E|id')
      two_fourths.reduce()
      one_half = new Id('B|C|id')

      two_halves = new Id('C|C|id')
      two_halves.reduce()
      one = new Id('B|B|id')

      manually_compare = (id1, id2) ->
        assert id1.numerator = id2.numerator
        assert id1.denominator = id2.denominator
        assert id1.participant_id = id2.participant_id

      manually_compare(three_fourths, six_eights)
      manually_compare(one_half, two_fourths)
      manually_compare(one, two_halves)

  describe "test from_neighbors", () ->
    it "should pick a value exactly between when it has to", () ->
      zero = new Id('A|B|id')
      one_half = new Id('B|C|id')
      one_fourth = new Id('B|E|id')

      between = new Id()
      between.from_neighbors(zero, one_half, 'id')

      assert one_fourth.compare(between) == 0

    it "should pick a value with the left side's base when it can", () ->
      one_fourth = new Id('B|E|id')
      one_half = new Id('B|C|id')
      three_fourths = new Id('D|E|id')

      between = new Id()
      between.from_neighbors(one_fourth, three_fourths, 'id')

      assert one_half.compare(between) == 0