assert = require('assert')
{Character} = require('../../../public/javascripts/lib/meta_string/character.coffee')
constants = require('../../../public/javascripts/lib/constants.coffee')
meta_string = require('../../../public/javascripts/lib/meta_string/meta_string.coffee')

describe "meta_string_tests", () ->

  describe "test _compress_display_character_list", () ->
    it "should return empty list on empty list", () ->
      assert meta_string._compress_display_character_list([]).length == 0

    it "should return a list of only html characters unchanged", () ->
      list = [new Character('', 'html'), new Character('', 'html')]

      compressed = meta_string._compress_display_character_list list
      assert compressed.length == list.length
      for character, index in compressed
        assert character.equals(list[index])

    it "should compress a list with display characters", () ->
      list = [new Character('', 'html'), new Character('a'), new Character('b'),
              new Character('', 'html'), new Character('a'), new Character('b')]
      expected = ['', 'ab', '', 'ab']
      compressed = meta_string._compress_display_character_list list
      assert compressed.length == expected.length
      for character, index in compressed
        assert character.display == expected[index]

  describe "test _node_to_tags", () ->
    it "should return an empty object for a tag not in the map", () ->
      node = tagName: 'NOT_REAL_TAG_NAME'
      tags = meta_string._node_to_tags node
      assert (key for own key of tags).length == 0

    it "should return a start and end tag of the tag in the mapping", () ->
      node = tagName: 'DIV'
      expected_tag = constants.DOM_TAGS[node.tagName.toLowerCase()]
      tags = meta_string._node_to_tags node
      assert (key for own key of tags).length == 2

      assert tags.open_tag.is_html()
      assert tags.open_tag.html == expected_tag
      assert tags.open_tag.is_start()

      assert tags.close_tag.is_html()
      assert tags.close_tag.html == expected_tag
      assert not tags.close_tag.is_start()

  describe "test _string_to_character_list", () ->
    it "should return the empty list on an empty string", () ->
      assert meta_string._string_to_character_list('').length == 0

    it "should return a list of characters that aren't html", () ->
      string = 'asdf'
      list = meta_string._string_to_character_list string
      for character, index in list
        assert string.charAt(index) == character.display
        assert not character.is_html()
