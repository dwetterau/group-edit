assert = require('assert')
{Character} = require('../../../public/javascripts/lib/meta_string/character.coffee')

describe 'character_tests', () ->

  describe 'test equals', () ->
    it 'should say equal characters are equal', () ->
      character_1 = new Character('display', 'html', true)
      character_2 = new Character('display', 'html', true)
      assert character_1.equals character_2
      assert character_2.equals character_1

      assert character_1.equals character_1

      character_1 = new Character('display', 'html')
      character_2 = new Character('display', 'html')
      assert character_1.equals character_2
      assert character_2.equals character_1

      character_1 = new Character('display')
      character_2 = new Character('display')
      assert character_1.equals character_2
      assert character_2.equals character_1

    it 'should say characters with different display are different', () ->
      character_1 = new Character('display_1', 'html', true)
      character_2 = new Character('display_2', 'html', true)
      assert not character_1.equals character_2
      assert not character_2.equals character_1

    it 'should say characters with different html are different', () ->
      character_1 = new Character('display', 'html_1', true)
      character_2 = new Character('display', 'html_2', true)
      assert not character_1.equals character_2
      assert not character_2.equals character_1

    it 'should say characters with different is_start are different', () ->
      character_1 = new Character('display', 'html', true)
      character_2 = new Character('display', 'html', false)
      assert not character_1.equals character_2
      assert not character_2.equals character_1

  describe 'test is_start', () ->
    it 'should say that characters without is_start set are not start tags', () ->
      character = new Character('display', 'html')
      assert not character.is_start()

    it 'should correctly return is_start when set', () ->
      character_false = new Character('display', 'html', false)
      character_true = new Character('display', 'html', true)

      assert not character_false.is_start()
      assert character_true.is_start()

  describe 'test is_html', () ->
    it 'should say characters with display are not html', () ->
      character = new Character('display', 'html', true)
      assert not character.is_html()

    it 'should say characters without html are not html', () ->
      character_undefined = new Character(undefined, undefined, true)
      character_empty = new Character('', '', true)
      assert not character_undefined.is_html()
      assert not character_empty.is_html()

    it 'should say characters with html are html', () ->
      character_display_empty = new Character('', 'html', true)
      character_no_display = new Character(undefined, 'html', true)
      assert character_display_empty.is_html()
      assert character_no_display.is_html()
