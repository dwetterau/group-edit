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