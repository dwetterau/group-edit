assert = require('assert')
diff = require('../../../public/javascripts/lib/diff/diff.coffee')
{Character} = require('../../../public/javascripts/lib/meta_string/character.coffee')

describe 'diff_tests', () ->
  string_ab = [new Character('A'), new Character('B')]
  string_ba = [new Character('B'), new Character('A')]
  string_abc = [new Character('A'), new Character('B'), new Character('C')]

  describe 'test_index', () ->
    it 'should return a simple index object', () ->
      expected =
        row: 0,
        column: 1
      index = diff._index(expected.row, expected.column)
      assert.equal index.row, expected.row
      assert.equal index.column, expected.column

  describe 'test_lcs', () ->
    it 'should return a 1 row matrix for an empty start', () ->
      end = string_ab
      matrix = diff._lcs([], end)

      assert.equal matrix.length, 1

      # The length of the row should be one more than the string
      assert.equal matrix[0].length, end.length + 1

      # Every value in the matrix should have value 0
      for element in matrix[0].length
        assert.equal element.value, 0

    it 'should return a 1 column matrix for an empty end', () ->
      start = string_ab
      matrix = diff._lcs(start, [])

      # The number of rows should be start + 1
      assert.equal matrix.length, start.length + 1

      # The length of each row should be one and the value of each element should be 0
      for row in matrix
        assert.equal row.length, 1
        assert.equal row[0].value, 0

    it 'should work on some sample inputs', () ->

      matrix = diff._lcs(string_ab, string_abc)

      # Check the expected dimensions
      assert.equal matrix.length, string_ab.length + 1
      assert.equal matrix[0].length, string_abc.length + 1

      # Check each value
      expected =
        0: [0, 0, 0, 0]
        1: [0, 1, 1, 1]
        2: [0, 1, 2, 2]
      for r in [0...matrix.length]
        for c in [0...matrix[r].length]
          assert.equal matrix[r][c].value, expected[r][c]

      matrix = diff._lcs(string_ab, string_ba)

      # Check the expected dimensions
      assert.equal matrix.length, string_ab.length + 1
      assert.equal matrix[0].length, string_ba.length + 1

      # Check each value
      expected =
        0: [0, 0, 0]
        1: [0, 0, 1]
        2: [0, 1, 1]

      for r in [0...matrix.length]
        for c in [0...matrix[r].length]
          assert.equal matrix[r][c].value, expected[r][c]

  describe 'test_backtrack', () ->
    it 'should return no operations for empty start and end', () ->
      operations = diff.diff [], []
      assert.equal operations.length, 0

    it 'should return all inserts for empty start and valid end', () ->
      end = string_ab

      matrix = diff._lcs [], end
      operations = diff._backtrack matrix
      assert.equal operations.length, end.length

      for operation, index in operations
        assert.equal operation.length, 2

        # Make sure it's an insert operation
        assert.equal operation[0], 1

        # Make sure that the character is what we expect
        assert.equal operation[1], end[index]

    it 'should return all deletes for valid start and empty end', () ->
      start = string_ab

      matrix = diff._lcs start, []
      operations = diff._backtrack matrix
      assert.equal operations.length, start.length

      for operation, index in operations
        assert.equal operation.length, 2

        # Make sure it's a delete operation
        assert.equal operation[0], -1

        # Make sure that the character is what we expect
        assert.equal operation[1], start[index]

    it 'should return all no change events when diffing the same string', () ->
      start = string_ab
      end = string_ab

      matrix = diff._lcs start, end
      operations = diff._backtrack matrix
      assert.equal operations.length, start.length

      for operation, index in operations
        assert.equal operation.length, 2

        # Make sure it's a "don't change" operation
        assert.equal operation[0], 0

        # Make sure that the character is what we expect
        assert.equal operation[1], start[index]

    it 'should correctly diff on some inputs', () ->
      # ab -> abc should generate 2 "don't change" events and one insert
      start = string_ab
      end = string_abc

      matrix = diff._lcs start, end
      operations = diff._backtrack matrix
      assert.equal operations.length, end.length

      expected =
        ops: [0, 0, 1]
        chars: end
      for operation, index in operations
        assert.equal operation.length, 2

        # Make sure the op type and characters match
        assert.equal operation[0], expected.ops[index]
        assert operation[1].equals(expected.chars[index])

      # ab -> ba should generate a delete of the a, a keep of the b, and an insert of the a
      start = string_ab
      end = string_ba

      matrix = diff._lcs start, end
      operations = diff._backtrack matrix
      assert.equal operations.length, end.length + 1

      expected =
        ops: [1, 0, -1]
        chars: [end[0], start[0], start[1]]

      for operation, index in operations
        assert.equal operation.length, 2

        # Make sure the op type and characters match
        assert.equal operation[0], expected.ops[index]
        assert operation[1].equals(expected.chars[index])

  describe 'test_compress', () ->
    it 'should return empty on empty', () ->
      operations = diff._compress []
      assert.equal operations.length, 0

    it 'should return the input if not compressible', () ->
      operations = [[1, 'a'], [0, 'b']]
      compressed = diff._compress operations

      assert.equal compressed.length, operations.length
      for operation, index in compressed
        assert.equal operation[0], operations[index][0]
        assert.equal operation[1][0], operations[index][1]

    it 'should compress consecutive operations', () ->
      operations = [[1, 'a'], [0, 'b'], [0, 'c']]
      compressed = diff._compress operations

      expected = [
        [1, ['a']]
        [0, ['b', 'c']]
      ]
      assert.equal compressed.length, expected.length
      for operation, index in compressed
        assert.equal operation[0], expected[index][0]
        assert.equal operation[1].length, expected[index][1].length
        for character, character_index in operation[1]
          assert.equal character, expected[index][1][character_index]
