# repmove.nvim

A Neovim plugin that lets `;` and `,` repeat a wide range of motions and jump actions—so you can replay your last navigation (not just f/t) forward or backward with consistent behavior.

[中文文档](README_zh.md)

## ✨ Motivation

My inspiration for writing this plugin comes from [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects). When I first started using nvim-treesitter-textobjects, it supported using semicolons (`;`) and commas (`,`) for repeat movement, which I thought was a great experience. 

However, I encountered a problem: if I needed to add repeat movement support for a new motion, I had to depend on nvim-treesitter-textobjects. This seemed a bit strange because nvim-treesitter-textobjects should only be a plugin that provides textobjects functionality, and shouldn't require all other plugins with movement operations to depend on it.

The main issue arose when I discovered [flash.nvim](https://github.com/folke/flash.nvim) and started using it heavily for navigation. If I enabled flash.nvim's functionality for binding semicolons and commas, it would hijack the repeat movement functionality. So I initially wrote a simple repmove module in my dotfiles.

Later I realized that many people would face the same issue when using both nvim-treesitter-textobjects and flash.nvim (or other jump plugins) together. Hence, this plugin was born. It can theoretically be combined with any jump plugin and provides a consistent interface for repeat movement.

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "Kaiser-Yang/repmove.nvim",
  config = function()
    -- See configuration section below
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'Kaiser-Yang/repmove.nvim',
  config = function()
    -- See configuration section below
  end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'Kaiser-Yang/repmove.nvim'
```

## 🚀 Quick Start

### Default Usage (without other jump plugins)

If you don't use other jump plugins and just want to add repeat movement support to the default `f`, `F`, `t`, `T` motions:

```lua
local repmove = require('repmove')

-- Create repeatable versions of f and F
local f_backward, f_forward = repmove.make('F', 'f', ',', ';')

-- Bind to keys
vim.keymap.set({ 'n', 'x', 'o' }, 'f', f_forward, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'F', f_backward, { expr = true })

-- Bind comma and semicolon to repeat
vim.keymap.set({ 'n', 'x', 'o' }, ';', repmove.semicolon, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, ',', repmove.comma, { expr = true })
```

### Usage with flash.nvim

If you're using flash.nvim or similar jump plugins, you need to:

1. Bind flash.nvim's functions to other keys (e.g., `<Plug>` mappings)
2. Use repmove.nvim to create repeatable versions
3. Bind `;` and `,` to repmove's repeat functions

```lua
local repmove = require('repmove')
local flash = require('flash')

-- First, create Plug-style mappings for flash functions
vim.keymap.set({ 'n', 'x', 'o' }, '<Plug>(flash-f)', function()
  flash.jump({ pattern = vim.fn.getcmdline() })
end)

vim.keymap.set({ 'n', 'x', 'o' }, '<Plug>(flash-F)', function()
  flash.jump({ pattern = vim.fn.getcmdline(), search = { forward = false } })
end)

vim.keymap.set({ 'n', 'x', 'o' }, '<Plug>(flash-t)', function()
  flash.jump({ pattern = vim.fn.getcmdline(), offset = -1 })
end)

vim.keymap.set({ 'n', 'x', 'o' }, '<Plug>(flash-T)', function()
  flash.jump({ pattern = vim.fn.getcmdline(), search = { forward = false }, offset = 1 })
end)

-- Create repeatable versions
local f_backward, f_forward = repmove.make(
  '<Plug>(flash-F)',  -- prev: backward search
  '<Plug>(flash-f)',  -- next: forward search
  '<Plug>(flash-F)',  -- what comma calls (backward)
  '<Plug>(flash-f)'   -- what semicolon calls (forward)
)

local t_backward, t_forward = repmove.make(
  '<Plug>(flash-T)',
  '<Plug>(flash-t)',
  '<Plug>(flash-T)',
  '<Plug>(flash-t)'
)

-- Bind to keys
vim.keymap.set({ 'n', 'x', 'o' }, 'f', f_forward, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'F', f_backward, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 't', t_forward, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'T', t_backward, { expr = true })

-- Bind comma and semicolon to repeat
vim.keymap.set({ 'n', 'x', 'o' }, ';', repmove.semicolon, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, ',', repmove.comma, { expr = true })
```

## 📖 API Documentation

### `repmove.make(prev, next, comma, semicolon)`

Creates a pair of repeatable motion functions.

**Parameters:**
- `prev` (function|string): The backward motion function or key mapping
- `next` (function|string): The forward motion function or key mapping
- `comma` (function|string, optional): Function to call when `,` is pressed (defaults to `prev`)
- `semicolon` (function|string, optional): Function to call when `;` is pressed (defaults to `next`)

**Returns:**
- `function`: The backward motion wrapper (to be bound to your backward key, e.g., `F`)
- `function`: The forward motion wrapper (to be bound to your forward key, e.g., `f`)

**Example:**
```lua
-- Simple usage
local backward_motion, forward_motion = repmove.make('F', 'f')

-- With custom repeat behavior
local backward_motion, forward_motion = repmove.make('F', 'f', ',', ';')

-- With flash.nvim
local backward_motion, forward_motion = repmove.make(
  '<Plug>(flash-F)',
  '<Plug>(flash-f)',
  '<Plug>(flash-F)',
  '<Plug>(flash-f)'
)
```

### `repmove.semicolon()`

Repeats the last motion forward. This should be bound to `;` key.

**Returns:**
- The result of calling the last forward motion

**Example:**
```lua
vim.keymap.set({ 'n', 'x', 'o' }, ';', repmove.semicolon, { expr = true })
```

### `repmove.comma()`

Repeats the last motion backward. This should be bound to `,` key.

**Returns:**
- The result of calling the last backward motion

**Example:**
```lua
vim.keymap.set({ 'n', 'x', 'o' }, ',', repmove.comma, { expr = true })
```

## 🔧 Advanced Configuration

### Using with nvim-treesitter-textobjects

```lua
local repmove = require('repmove')
local ts_repeat_move = require('nvim-treesitter.textobjects.repeatable_move')

-- Create repeatable versions of treesitter textobject moves
local next_func, prev_func = repmove.make(
  ts_repeat_move.builtin_F,
  ts_repeat_move.builtin_f,
  ts_repeat_move.builtin_F,
  ts_repeat_move.builtin_f
)

vim.keymap.set({ 'n', 'x', 'o' }, 'f', next_func, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'F', prev_func, { expr = true })

-- Bind comma and semicolon
vim.keymap.set({ 'n', 'x', 'o' }, ';', repmove.semicolon, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, ',', repmove.comma, { expr = true })
```

### Custom Motion Functions

You can also wrap custom Lua functions:

```lua
local repmove = require('repmove')

-- Custom motion functions
local function my_forward_search()
  -- Your custom search logic
  vim.fn.search('pattern', 'W')
end

local function my_backward_search()
  -- Your custom search logic
  vim.fn.search('pattern', 'bW')
end

-- Make them repeatable
local backward_motion, forward_motion = repmove.make(
  my_backward_search,
  my_forward_search,
  my_backward_search,
  my_forward_search
)

vim.keymap.set({ 'n', 'x', 'o' }, '<leader>n', forward_motion, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, '<leader>N', backward_motion, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, ';', repmove.semicolon, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, ',', repmove.comma, { expr = true })
```

## 💡 How It Works

The plugin works by wrapping your motion functions and storing the last used motion. When you press `;` or `,`, it replays the last motion in the appropriate direction.

The key insight is that `repmove.make()` returns **wrapper functions** that:
1. Store the motion as the "last used motion" when executed
2. Execute the original motion function
3. Return the result to Neovim

When you press `;` or `,`, `repmove.semicolon()` or `repmove.comma()` simply calls the stored forward or backward motion function.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) - For the original inspiration
- [flash.nvim](https://github.com/folke/flash.nvim) - For the excellent jump plugin that prompted the creation of this plugin
