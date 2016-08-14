assert = require('assert')
tokenize = require('../src/tokenize')

describe("tokenize", ->
    it("ignores whitespace", ->
        assert.deepEqual(tokenize("a=1"), ["a", "=", "1"])
        assert.deepEqual(tokenize("a =1"), ["a", "=", "1"])
        assert.deepEqual(tokenize("a= 1 "), ["a", "=", "1"])
        assert.deepEqual(tokenize("a = 1"), ["a", "=", "1"])
    )

    it("handles numbers", ->
        assert.deepEqual(tokenize("a=1"), ["a", "=", "1"])
        assert.deepEqual(tokenize("a = 1"), ["a", "=", "1"])
        assert.deepEqual(tokenize("a = 1.5"), ["a", "=", "1.5"])
        assert.deepEqual(tokenize("a = 1."), ["a", "=", "1."])
    )

    it("handles strings", ->
        assert.deepEqual(tokenize('a = "hello"'), ["a", "=", '"hello"'])
        assert.deepEqual(tokenize('a = "hello world"'), ["a", "=", '"hello world"'])
    )

    it("handles arrays", ->
        assert.deepEqual(tokenize('a = [1, 2, 3]'), ["a", "=", '[', '1', ',', '2', ',', '3', ']'])
        assert.deepEqual(tokenize('a = [1, "a", 3]'), ["a", "=", '[', '1', ',', '"a"', ',', '3', ']'])
    )

    it("handles functions", ->
        assert.deepEqual(tokenize('a = () -> \n    a = 1'), ["a", "=", '(', ')', '->', '$NEWLINE$', '$INDENT$', 'a', '=', '1'])
        assert.deepEqual(tokenize('a = () -> \n    a = 1\nn=2'), ["a", "=", '(', ')', '->', '$NEWLINE$', '$INDENT$', 'a', '=', '1', '$NEWLINE$', '$OUTDENT$','n','=','2'])
        assert.deepEqual(tokenize('a = () -> \n    a = 1\n    n=2'), ["a", "=", '(', ')', '->', '$NEWLINE$', '$INDENT$', 'a', '=', '1', '$NEWLINE$','n','=','2'])
    )

    it("handles everything", ->
        code = """
a = 1
b = "hello world"
c = [0, 1, 2, 3, 4, 5]
d = (value) ->
    println(value * 2)
    for i in c
        d(i)
while a > 0 and c.length < 10
    println(a)
    a = a - 1
"""
        tokens = [
            'a', '=', '1',
            '$NEWLINE$',
            'b', '=', '"hello world"',
            '$NEWLINE$',
            'c', '=', '[', '0', ',', '1', ',', '2', ',', '3', ',', '4', ',', '5', ']',
            '$NEWLINE$',
            'd', '=', '(', 'value', ')', '->',
            '$NEWLINE$',
            '$INDENT$', 'println', '(', 'value', '2', ')',
            '$NEWLINE$',
            'for', 'i', 'in', 'c',
            '$NEWLINE$',
            '$INDENT$', 'd', '(', 'i', ')', '$NEWLINE$',
            '$OUTDENT$',
            '$OUTDENT$',
            'while', 'a', '>', '0', 'and', 'c', '.', 'length', '<', '10'
            '$NEWLINE$',
            '$INDENT$','println','(','a',')',
            '$NEWLINE$',
            'a','=','a','-','1'
        ]
        assert.deepEqual(tokenize(code), tokens)
    )
)
