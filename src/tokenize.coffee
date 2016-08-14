###
TurtleScript Tokenizer
-------------------------------------------------------------------------------
This is a finite state machine inspired tokenizer which transforms turtlescript 
source code into a stream of tokens. For the most part, it is a fairly standard
FSM which transitions between different types of tokens; however, there is some
custom logic for handling "nested" indentations and "->" function operators. It 
uses nested if/else blocks to implement the state transition logic.
-------------------------------------------------------------------------------
Kevin Zhang <kevz@mit.edu> | August 14th, 2016
###

STATE = {
    NEWLINE:      1
    INDENTATION:  2
    WHITESPACE:   3
    IDENTIFIER:   4
    NUMERIC:      5
    NUMERICDOT:   6
    SYMBOLIC:     7
    STRING:       8
    ENDSTRING:    9
    ESCAPESTRING: 10
}

isNewline = (char) ->
    return char == '\n'

isWhitespace = (char) ->
    return char == ' ' or char == '\t'

isLetter = (char) ->
    return 'a' <= char <= 'z' or 'A' <= char <= 'Z'

isDigit = (char) ->
    return '0' <= char <= '9'

isDecimalPoint = (char) ->
    return char == '.'

isSymbol = (char) ->
    if char in ['=', '.', '[', ',', ']', '(', ')', '-', '>', '<']
        return true
    return false

isQuote = (char) ->
    return char == '"'

tokenize = (str) ->
    tokens = []
    arr = str.split('')
    state = STATE.NEWLINE

    token = ""
    one_indent = 0
    prev_indent = 0
    while arr.length > 0
        char = arr.shift()

        if state == STATE.NEWLINE
            tokens.push("$NEWLINE$")
            token = ''
            if isWhitespace(char)
                state = STATE.INDENTATION
                token += char
            else
                if prev_indent > 0 and one_indent
                    for i in [0...prev_indent / one_indent]
                        tokens.push("$OUTDENT$")
                    prev_indent = 0

                if isLetter(char)
                    state = STATE.IDENTIFIER
                    token += char
                if isDigit(char) or isDecimalPoint(char)
                    state = STATE.NUMERIC
                    token += char
                if isSymbol(char)
                    state = STATE.SYMBOLIC
                    token += char
                if isQuote(char)
                    state = STATE.STRING
                    token += char

        else if state == STATE.INDENTATION
            if isWhitespace(char)
                state = STATE.INDENTATION
                token += char
            else
                if token.length > prev_indent
                    num_indent = 1
                    if one_indent != 0
                        num_indent = (token.length - prev_indent) / one_indent
                    for i in [0...num_indent]
                        tokens.push("$INDENT$")
                if token.length < prev_indent
                    num_indent = 1
                    if one_indent != 0
                        num_indent = (token.length - prev_indent) / one_indent
                    for i in [0...num_indent]
                        tokens.push("$INDENT$")
                    tokens.push("$OUTDENT$")
                if one_indent == 0
                    one_indent = token.length
                prev_indent = token.length

                token = ""
                if isLetter(char)
                    state = STATE.IDENTIFIER
                    token = char
                if isDigit(char)
                    state = STATE.NUMERIC
                    token = char
                if isSymbol(char)
                    state = STATE.SYMBOLIC
                    token = char
                if isQuote(char)
                    state = STATE.STRING
                    token = char

        else if state == STATE.WHITESPACE
            if isWhitespace(char)
                state = STATE.WHITESPACE
                token += char
            else
                token = ""
                if isLetter(char)
                    state = STATE.IDENTIFIER
                    token = char
                if isDigit(char)
                    state = STATE.NUMERIC
                    token = char
                if isSymbol(char)
                    state = STATE.SYMBOLIC
                    token = char
                if isQuote(char)
                    state = STATE.STRING
                    token = char
                if isNewline(char)
                    state = STATE.NEWLINE
                    token = char

        else if state == STATE.IDENTIFIER
            if isWhitespace(char)
                state = STATE.WHITESPACE
                tokens.push(token)
                token = char
            else if isNewline(char)
                state = STATE.NEWLINE
                tokens.push(token)
                token = char
            else if isLetter(char)
                state = STATE.IDENTIFIER
                token += char
            else if isDigit(char)
                state = STATE.IDENTIFIER
                token += char
            else if isSymbol(char)
                state = STATE.SYMBOLIC
                tokens.push(token)
                token = char
            else if isQuote(char)
                state = STATE.STRING
                tokens.push(token)
                token = char

        else if state == STATE.NUMERIC
            if isWhitespace(char)
                state = STATE.WHITESPACE
                tokens.push(token)
                token = char
            else if isNewline(char)
                state = STATE.NEWLINE
                tokens.push(token)
                token = char
            else if isLetter(char)
                state = STATE.IDENTIFIER
                tokens.push(token)
                token = char
            else if isDigit(char)
                state = STATE.NUMERIC
                token += char
            else if isDecimalPoint(char)
                state = STATE.NUMERICDOT
                token += char
            else if isSymbol(char)
                state = STATE.SYMBOLIC
                tokens.push(token)
                token = char
            else if isQuote(char)
                state = STATE.STRING
                tokens.push(token)
                token = char

        else if state == STATE.NUMERICDOT
            if isWhitespace(char)
                state = STATE.WHITESPACE
                tokens.push(token)
                token = char
            else if isNewline(char)
                state = STATE.NEWLINE
                tokens.push(token)
                token = char
            else if isLetter(char)
                state = STATE.IDENTIFIER
                tokens.push(token)
                token = char
            else if isDigit(char)
                state = STATE.NUMERICDOT
                token += char
            else if isSymbol(char) 
                state = STATE.SYMBOLIC
                tokens.push(token)
                token = char
            else if isQuote(char)
                state = STATE.STRING
                tokens.push(token)
                token = char

        else if state == STATE.SYMBOLIC
            if isWhitespace(char)
                state = STATE.WHITESPACE
                tokens.push(token)
                token = char
            else if isNewline(char)
                state = STATE.NEWLINE
                tokens.push(token)
                token = char
            else if isLetter(char)
                state = STATE.IDENTIFIER
                tokens.push(token)
                token = char
            else if isDigit(char)
                state = STATE.NUMERIC
                tokens.push(token)
                token = char
            else if isSymbol(char) 
                state = STATE.SYMBOLIC
                if token == '-' and char == '>'
                    token += char
                else
                    tokens.push(token)
                    token = char
            else if isQuote(char)
                state = STATE.STRING
                tokens.push(token)
                token = char

        else if state == STATE.STRING
            if not isQuote(char)
                if char == "\\"
                    state = STATE.ESCAPESTRING
                token += char
            else
                state = STATE.ENDSTRING
                token += char

        else if state == STATE.ENDSTRING
            if isWhitespace(char)
                state = STATE.WHITESPACE
                tokens.push(token)
                token = char
            else if isNewline(char)
                state = STATE.NEWLINE
                tokens.push(token)
                token = char
            else if isLetter(char)
                state = STATE.IDENTIFIER
                tokens.push(token)
                token = char
            else if isDigit(char)
                state = STATE.NUMERIC
                tokens.push(token)
                token = char
            else if isSymbol(char) 
                state = STATE.SYMBOLIC
                tokens.push(token)
                token = char
            else if isQuote(char)
                state = STATE.STRING
                tokens.push(token)
                token = char

        else if state == STATE.ESCAPESTRING
            state = STATE.STRING
            token += char

    if not isWhitespace(token)
        tokens.push(token)
    return tokens.slice(1)

module.exports = tokenize
