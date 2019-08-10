# lbf
lbf is a brainfuck interpreter/compiler written in lua. It supports AST optimization as well as backends for multiple languages, including brainfuck itself.

## Installing
For now, the best way to install lbf is to clone this repo, and install `argparse` from luarocks. Running lbf must be done from its directory until a packaged version is available.

## Available backends
- `run`: simply run the given brainfuck program
- `lua`: generate Lua code
- `luarun`: generate Lua code and run it; it has a long startup time, but is the fastest to execute
- `js`: genetate JavaScript code meant for a browser, using `prompt` and `alert`
- `bf`: generate brainfuck code, useful to optimize a program
- `fastc`: generates C code without any safety check

