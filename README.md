# repmove.nvim

A Neovim plugin that lets ; and , repeat a wide range of motions and jump
actions. Therefore you can replay your last navigation (not just f/t) forward
or backward with consistent behavior.

`repmove.make(prev, next, backward, forward, filetypes)` accepts an optional
`filetypes` argument (`string` or `string[]`) to scope the repeat behavior
to specific filetypes.
