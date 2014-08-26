assert = require('assert')
diff = require('../../../public/javascripts/lib/diff/diff')
Character = require('../../../public/javascripts/lib/meta_string/character').Character

describe 'diff_tests', () ->
  describe 'test_index', () ->
    it 'should return a simple index object', (done) ->
      expected =
        row: 0,
        column: 1
      index = diff._index(expected.row, expected.column)
      assert.equal index.row, expected.row
      assert.equal index.column, expected.column
      done()

  describe 'test_lcs', () ->
    it 'should return a 1 row matrix for an empty start', (done) ->
      end = [new Character('A'), new Character('B')]
      matrix = diff._lcs([], end)

      assert.equal matrix.length, 1

      # The length of the row should be one more than the string
      assert.equal matrix[0].length, end.length + 1

      # Every value in the matrix should have value 0
      for element in matrix[0].length
        assert.equal element.value, 0

      done()