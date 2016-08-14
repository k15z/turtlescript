###
TurtleScript v0.0.1
-------------------------------------------------------------------------------
This is a toy programming language which combines the best parts of javascript,
coffeescript, and python to create a tiny but awesome programming language. The
standard library is more-or-less nonexistent and there are no plans for interop
support, but still...
-------------------------------------------------------------------------------
Kevin Zhang <kevz@mit.edu> | August 13th, 2016
###

parse = require('./parse')
tokenize = require('./tokenize')

module.exports = (src) ->
    return parse(tokenize(src))
