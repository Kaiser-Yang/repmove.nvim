# repmove.nvim

[English](README.md) | [中文](README-zh.md)

---

## Introduction

**repmove.nvim** is a Neovim plugin that enables `;` and `,` to repeat a wide range of motions and jump actions—allowing you to replay your last navigation (not just `f`/`t`) forward or backward with consistent behavior.

## Motivation

The inspiration for this plugin came from **nvim-treesitter-textobjects**. Initially, nvim-treesitter-textobjects supported repeating movements using semicolon and comma, which provided an excellent user experience. However, a problem emerged: if you wanted to add repeat-move support for a new motion, you had to depend on nvim-treesitter-textobjects. This seemed odd because nvim-treesitter-textobjects should only be a plugin that provides textobject functionality, not something that all other plugins with movement operations should depend on.

The main issue became apparent when discovering and using **flash.nvim**. When flash.nvim's feature to bind semicolon and comma was enabled, it would hijack these keys and interfere with the repeat movement functionality. This led to the creation of this standalone plugin that can work with any jump plugin without creating unwanted dependencies.

## Features

- ✨ **Universal Repeat Movement**: Use `;` and `,` to repeat any motion, not just built-in `f`/`t`
- 🔌 **Plugin Agnostic**: Works with any jump plugin (flash.nvim, leap.nvim, hop.nvim, etc.)
- 🎯 **Simple API**: Easy-to-use `make()` function to wrap your motions
- 🚀 **Zero Dependencies**: Lightweight and standalone
- 🔄 **Bidirectional**: Automatically handles forward and backward repetition

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'Kaiser-Yang/repmove.nvim',
  config = function()
    -- Your configuration here
  end
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  'Kaiser-Yang/repmove.nvim',
  config = function()
    -- Your configuration here
  end
}
```

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'Kaiser-Yang/repmove.nvim'
```

## Quick Start

### Basic Usage (Built-in Neovim Motions)

If you're not using any other jump plugin, you can easily wrap Neovim's built-in `f`/`F` motions:

```lua
local repmove = require('repmove')

-- Create repeatable versions of f and F
local prev_f, next_f = repmove.make('F', 'f', ',', ';')

-- Map to keys
vim.keymap.set({'n', 'x', 'o'}, 'f', next_f, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, 'F', prev_f, { expr = true })

-- Map ; and , to repeat the motion
vim.keymap.set({'n', 'x', 'o'}, ';', repmove.semicolon, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, ',', repmove.comma, { expr = true })
```

### Integration with flash.nvim

Here's how to integrate repmove.nvim with [flash.nvim](https://github.com/folke/flash.nvim):

```lua
local repmove = require('repmove')

-- Configure flash.nvim to use different keys
require('flash').setup({
  modes = {
    char = {
      enabled = true,
      keys = { "f", "F", "t", "T" },
      -- Don't bind ; and , in flash
      jump_labels = false,
    },
  },
})

-- Create repeatable versions using flash's functions
local prev_f, next_f = repmove.make(
  function() require('flash').jump({ forward = false, pattern = vim.fn.getcmdline() }) end,
  function() require('flash').jump({ forward = true, pattern = vim.fn.getcmdline() }) end,
  function() require('flash').jump({ forward = false, pattern = vim.fn.getcmdline() }) end,
  function() require('flash').jump({ forward = true, pattern = vim.fn.getcmdline() }) end
)

-- Or more simply, using flash's existing keymaps as references
vim.keymap.set({'n', 'x', 'o'}, 'f', function()
  require('flash').jump({ forward = true })
end)
vim.keymap.set({'n', 'x', 'o'}, 'F', function()
  require('flash').jump({ forward = false })
end)

-- Map ; and , to repeat ANY motion
vim.keymap.set({'n', 'x', 'o'}, ';', repmove.semicolon, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, ',', repmove.comma, { expr = true })
```

## API Documentation

### `repmove.make(prev, next, comma, semicolon)`

Creates a pair of functions that support repeat movement.

**Parameters:**
- `prev` (`function|string`): The "backward" motion command or function
- `next` (`function|string`): The "forward" motion command or function  
- `comma` (`function|string`, optional): What to execute when `,` is pressed (defaults to `prev`)
- `semicolon` (`function|string`, optional): What to execute when `;` is pressed (defaults to `next`)

**Returns:**
- `function`: The wrapped "prev" function (for backward motion)
- `function`: The wrapped "next" function (for forward motion)

**Example:**
```lua
-- Simple case: wrap built-in f and F
local prev_f, next_f = repmove.make('F', 'f', ',', ';')

-- Custom functions
local prev_custom, next_custom = repmove.make(
  function() print('going backward') end,
  function() print('going forward') end
)
```

### `repmove.semicolon()`

Returns a function that repeats the last motion forward.

**Usage:**
```lua
vim.keymap.set({'n', 'x', 'o'}, ';', repmove.semicolon, { expr = true })
```

### `repmove.comma()`

Returns a function that repeats the last motion backward.

**Usage:**
```lua
vim.keymap.set({'n', 'x', 'o'}, ',', repmove.comma, { expr = true })
```

## Advanced Examples

### Example 1: Using with nvim-treesitter-textobjects

```lua
local repmove = require('repmove')
local ts_repeat_move = require('nvim-treesitter.textobjects.repeatable_move')

-- Make treesitter motions repeatable
local prev_func, next_func = repmove.make(
  ts_repeat_move.builtin_F,
  ts_repeat_move.builtin_f,
  ',',
  ';'
)

vim.keymap.set({'n', 'x', 'o'}, 'f', next_func, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, 'F', prev_func, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, ';', repmove.semicolon, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, ',', repmove.comma, { expr = true })
```

### Example 2: Multiple Repeatable Motions

```lua
local repmove = require('repmove')

-- Repeatable f/F
local prev_f, next_f = repmove.make('F', 'f')
vim.keymap.set({'n', 'x', 'o'}, 'f', next_f, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, 'F', prev_f, { expr = true })

-- Repeatable t/T
local prev_t, next_t = repmove.make('T', 't')
vim.keymap.set({'n', 'x', 'o'}, 't', next_t, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, 'T', prev_t, { expr = true })

-- Repeatable search
local prev_search, next_search = repmove.make('N', 'n')
vim.keymap.set({'n', 'x', 'o'}, 'n', next_search, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, 'N', prev_search, { expr = true })

-- Map ; and , to repeat ANY of the above motions
vim.keymap.set({'n', 'x', 'o'}, ';', repmove.semicolon, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, ',', repmove.comma, { expr = true })
```

## How It Works

The plugin works by wrapping your motion functions and tracking the last executed motion. When you press `;` or `,`, it replays the last motion in the appropriate direction.

1. You wrap your motion with `repmove.make()` 
2. The wrapper stores the forward and backward versions
3. When you execute the motion, it updates the "last motion" state
4. Pressing `;` or `,` executes the stored motion

## License

MIT License - see [LICENSE](LICENSE) for details.

