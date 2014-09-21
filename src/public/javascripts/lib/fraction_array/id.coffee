Base64 = require 'base64-math'
constants = require '../constants.coffee'

class Id
  constructor: (string) ->
    if not string?
      @numerator = ''
      @denominator = ''
      @participant_id = ''

    split = string.split("|")
    assert split.length == 3

    @numerator = split[0]
    @denominator = split[1]
    @participant_id = split[2]

  to_string: () ->
    assert @numerator.length > 0 and @denominator.length > 0 and @participant_id.length > 0
    return @numerator + "|" + @denominator + "|" + @participant_id

  # This method compares two ids and if the first is smaller returns < 0, equal returns 0, bigger
  # returns > 0
  compare: (other) ->
    num1 = Base64.multiply(@numerator, other.denominator)
    num2 = Base64.multiply(other.numerator, @denominator)

    return Base64.compare(num1, num2)

  # This creates an id between the left and the right with the precondition that left < right
  # We try to not divide the denominator by 2 if at all possible
  from_neighbors: (left_id, right_id, participant_id) ->
    new_denom = Base64.lcm(left_id.denominator, right_id.denominator)

    left_factor = Base64.divide(new_denom, left_id.denominator)
    left_numerator = Base64.multiply(left_factor, left_id.numerator)

    right_factor = Base64.divide(new_denom, right_id.denominator)
    right_numerator = Base64.multiply(right_factor, right_id.numerator)

    difference = Base64.subtract(right_numerator, left_numerator)

    if Base64.compare(difference, constants.BASE64_ONE) > 0
      # Difference of more than 1, we have our new denominator already, get numerator as average
      combined_numerator = Base64.add(left_numerator, right_numerator)
      @numerator = Base64.right_shift(combined_numerator)
      @denominator = new_denom
    else
      # The numbers were right next to each other, double left and add 1 for numerator
      # Shift the denominator over to multiply by 2
      doubled_numerator = Base64.left_shift(left_numerator)
      @numerator = Base64.add(doubled_numerator, constants.BASE64_ONE)
      @denominator = Base64.right_shift(new_denom)

    # After we have set our new numerator and denominator, be sure to reduce
    @participant_id = participant_id
    @reduce()


  # This function makes sure that we are the canonical form of this value.
  reduce: () ->
    gcd = Base64.gcd(@numerator, @denominator)
    if Base64.compare(gcd, constants.BASE64_ONE) > 0
      @numerator = Base64.divide(@numerator, gcd)
      @denominator = Base64.divide(@denominator, gcd)

module.exports =
  Id: Id
