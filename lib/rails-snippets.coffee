# much love to @eddorre <3 <3
{Range} = require 'atom'
{CompositeDisposable} = require 'atom'

# erb supported blocks
ERB_BLOCKS = [['<%=', '%>'], ['<%', '%>'], ['<%#', '%>']]
ERB_REGEX = '<%(=?|-?|#?)\s{2}(-?)%>'
# matches the opening bracket
ERB_OPENER_REGEX = '<%[\\=\\#]?'
# matches the closing bracket.
ERB_CLOSER_REGEX = "%>"

module.exports =
  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'rails-snippets:toggleErb', => @toggleErb()

  toggleErb: ->
    editor = atom.workspace.getActiveTextEditor()
    for selection in editor.getSelections() by 1
      hasTextSelected = !selection.isEmpty()
      selectedText = selection.getText()
      delegate = @

      editor.transact ->
        selection.deleteSelectedText()
        currentCursor = selection.cursor
        # searching for opening and closing brackets
        [opener, closer] = delegate.findSorroundingBlocks editor, currentCursor
        if opener? and closer?
          # if both brackets found - replacing them with the next ones.
          delegate.replaceErbBlock editor, opener, closer, currentCursor
        else
          # if any of the brackets were't found - inserting new ones.
          delegate.insertErbBlock editor, currentCursor

        if hasTextSelected
          textToRestoreRange = editor.getBuffer().insert currentCursor.getBufferPosition(), selectedText
          selection.setBufferRange textToRestoreRange


  findSorroundingBlocks: (editor, currentCursor) ->
    opener = closer = null
    # grabbing the whole line
    containingLine = currentCursor.getCurrentLineBufferRange()

    # one region to the left of the cursor and one to the right
    leftRange  = new Range containingLine.start, currentCursor.getBufferPosition()
    rightRange = new Range currentCursor.getBufferPosition(), containingLine.end

    # searching in the left range for an opening bracket
    foundOpeners = []
    editor.getBuffer().scanInRange new RegExp(ERB_OPENER_REGEX, 'g'), leftRange, (result) ->
      foundOpeners.push result.range
    # if found, setting a range for it, using the last match - the rightmost bracket found
    opener = foundOpeners[foundOpeners.length - 1] if foundOpeners

    # searching in the right range for an opening bracket
    foundClosers = []
    editor.getBuffer().scanInRange new RegExp(ERB_CLOSER_REGEX, 'g'), rightRange, (result) ->
      foundClosers.push result.range
    # if found, setting a new range, using the first match - the leftmost bracket found
    closer = foundClosers[0] if foundClosers
    return [opener, closer]

  insertErbBlock: (editor, currentCursor) ->
    # inserting the first block in the list
    defaultBlock = ERB_BLOCKS[0]
    desiredPosition = null
    # inserting opening bracket
    openingTag = editor.getBuffer().insert currentCursor.getBufferPosition(), defaultBlock[0] + ' '
    # storing position between brackets
    desiredPosition = currentCursor.getBufferPosition()
    # inserting closing bracket
    closingBlock = editor.getBuffer().insert currentCursor.getBufferPosition(), ' ' + defaultBlock[1]
    currentCursor.setBufferPosition( desiredPosition )

  replaceErbBlock: (editor, opener, closer, currentCursor) ->
    # getting the next block in the list
    openingBracket = editor.getBuffer().getTextInRange opener
    closingBracket = editor.getBuffer().getTextInRange closer
    nextBlock = @getNextErbBlock editor, openingBracket, closingBracket
    # replacing in reverse order because line length might change
    editor.getBuffer().setTextInRange closer, nextBlock[1]
    editor.getBuffer().setTextInRange opener, nextBlock[0]

  getNextErbBlock: (editor, openingBracket, closingBracket) ->
    for block, i in ERB_BLOCKS
      if JSON.stringify([openingBracket, closingBracket]) == JSON.stringify(block)
        # if outside of scope - returning the first block
        return if (i + 1) >= ERB_BLOCKS.length then ERB_BLOCKS[0] else ERB_BLOCKS[i + 1]

    # in case we haven't found the block in the list, returning the first one
    return ERB_BLOCKS[0]
