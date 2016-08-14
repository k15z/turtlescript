# TurtleScript v0.0.1
This is a toy programming language which combines the best parts of javascript,
coffeescript, and python to create a tiny but awesome programming language. The
standard library is more-or-less nonexistent and there are no plans for interop
support, but still...

## Tokenizer
The lexer/tokenizer uses a FSM-based algorithm to transform a char array into a 
stream of tokens. The state machine is implemented using if/else blocks and the
algorithm for handling indentation and other corner cases is somewhat ad-hoc to
reduce the number of states.

## Parser
Coming soon...
