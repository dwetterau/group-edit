assert = require('assert')
meta_string = require('../../../public/javascripts/lib/meta_string/meta_string.coffee')

describe "meta_string_tests", () ->
  describe "test _string_to_character_list", () ->
    it "should return the empty list on an empty string", () ->
      assert meta_string._string_to_character_list('').length == 0

    it "should return a list of characters that aren't html", () ->
      string = 'asdf'
      list = meta_string._string_to_character_list string
      for character, index in list
        assert string.charAt(index) == character.display
        assert not character.is_html()
