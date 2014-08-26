class Element
  constructor: (@index, @value, @operation, @previous_index) ->

  get_previous: (matrix) ->
    if index.row == 0 and index.column == 0
      return undefined

    return matrix[@previous_index.row][@previous_index.column]

module.exports =
  _index: (row, column) ->
    index =
      row: row
      column: column
    return index

  _lcs: (ms_start, ms_end) ->
    # Allocate the giant array
    matrix = for r in [0...ms_start.length + 1]
      for c in [0...ms_end.length + 1]
        undefined

    matrix[0][0] = new Element({row: 0, column: 0}, 0)

    # fill in the top row, each element to the right is an insert
    for c in [1...ms_end.length + 1]
      matrix[0][c] = new Element(@_index(0, c), 0, [1, ms_end[c - 1]], @_index(0, c - 1))

    # fill in the down row, each element below is a deletion
    for r in [1...ms_start.length + 1]
      matrix[r][0] = new Element(@_index(r, 0), 0, [-1, ms_start[r - 1]], @_index(0, r - 1))

    for r in [1...ms_start.length + 1]
      for c in [1...ms_end.length + 1]
        current = @_index(r, c)
        if ms_start[r].equals(ms_end[c])
          # Yay the characters matched, insert a "0" operation here
          value = matrix[r - 1][c - 1].value + 1
          previous = @_index(r - 1, c - 1)
          operation = [0, ms_end[c]]
        else if matrix[r][c - 1].value > matrix[r - 1][c].value
          # In this case, the element to our left is bigger, so we want to do an insert
          value = matrix[r][c - 1].value
          previous = @_index(r, c - 1)
          operation = [1, ms_end[c]]
        else
          # In this case the element above is bigger or the same, do a delete
          value = matrix[r - 1][c].value
          previous = @_index(r - 1, c)
          operation = [-1, ms_start[r]]
        matrix[r][c] = new Element(current, value, operation, previous)

    return matrix

  _backtrack: (matrix) ->
    rows = matrix.length
    columns = matrix[0].length

    operation_list = []
    element = matrix[rows - 1][columns - 1]
    while element? and element.operation?
      operation_list.unshift element.operation
      element = element.get_previous(matrix)

    return operation_list

  diff: (ms_start, ms_end) ->
    # Takes in two meta_strings and diffs them
    matrix = @_lcs ms_start, ms_end
    return @_backtrack matrix
