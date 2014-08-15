define
  get_cursor: (element) ->
    if element.selectionStart
      return element.selectionStart
    else if document.selection
      element.focus()
      r = document.selection.createRange()
      if r == null
        return 0

      re = element.createTextRange()
      rc = re.duplicate()
      re.moveToBookmark r.getBookmark()
      rc.setEndPoint 'EndToStart', re
      return rc.text.length
    return 0

  set_cursor: (element, index) ->
    if element.createTextRange
      range = element.createTextRange()
      range.move 'character', index
      range.select()
    else
      if element.selectionStart
        element.focus()
        element.setSelectionRange index, index
      else
        element.focus()