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
  opts = {}
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  'Kaiser-Yang/repmove.nvim',
  config = function()
    require('repmove').setup()
  end
}
```

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'Kaiser-Yang/repmove.nvim'
```

## Quick Start

### Step 1: Bind Semicolon and Comma (Essential)

**This is the foundation of repmove.nvim.** You must bind `;` and `,` to the repeat functions. While you can technically use other keys, **semicolon and comma are highly recommended** as they follow Vim's traditional repeat motion keys.

```lua
local repmove = require('repmove')

-- Bind ; and , to repeat motions
vim.keymap.set({'n', 'x', 'o'}, ';', repmove.semicolon, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, ',', repmove.comma, { expr = true })
```

After setting this up, any motion you wrap with `repmove.make()` can be repeated using `;` (forward) and `,` (backward).

### Step 2: Wrap Your Motions

Now you can wrap any motion to make it repeatable:

#### Basic Usage (Built-in Neovim Motions)

If you're not using any other jump plugin, you can easily wrap Neovim's built-in `f`/`F` motions:

```lua
local repmove = require('repmove')

-- Bind ; and , first (required)
vim.keymap.set({'n', 'x', 'o'}, ';', repmove.semicolon, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, ',', repmove.comma, { expr = true })

-- Create repeatable versions of f and F
local prev_f, next_f = repmove.make('F', 'f')

-- Map to keys
vim.keymap.set({'n', 'x', 'o'}, 'f', next_f, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, 'F', prev_f, { expr = true })
```

Now `f` and `F` can be repeated with `;` and `,`!

#### Integration with flash.nvim

Here's how to integrate repmove.nvim with [flash.nvim](https://github.com/folke/flash.nvim):

```lua
local repmove = require('repmove')

-- Bind ; and , first (required)
vim.keymap.set({'n', 'x', 'o'}, ';', repmove.semicolon, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, ',', repmove.comma, { expr = true })

-- Configure flash.nvim (don't let it bind ; and ,)
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

-- Wrap flash motions with repmove
local function flash_jump(forward)
  return function()
    require('flash').jump({ forward = forward })
  end
end

local prev_flash, next_flash = repmove.make(flash_jump(false), flash_jump(true))

vim.keymap.set({'n', 'x', 'o'}, 'f', next_flash, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, 'F', prev_flash, { expr = true })
```

## API Documentation

### `repmove.make(prev, next, comma, semicolon)`

Creates a pair of functions that support repeat movement.

**Parameters:**
- `prev` (`function|string`): The "previous" motion command or function (typically moves backward, e.g., `F`)
- `next` (`function|string`): The "next" motion command or function (typically moves forward, e.g., `f`)
- `comma` (`function|string`, optional): What to execute when `,` is pressed (defaults to `prev`)
- `semicolon` (`function|string`, optional): What to execute when `;` is pressed (defaults to `next`)

**Returns:**
- `function`: The wrapped "prev" function 
- `function`: The wrapped "next" function

**Example:**
```lua
-- Simple case: wrap built-in f and F
local prev_f, next_f = repmove.make('F', 'f')

-- Custom functions
local prev_custom, next_custom = repmove.make(
  function() print('going to previous') end,
  function() print('going to next') end
)
```

### `repmove.semicolon()`

Executes the last motion in the forward/next direction.

**Usage:**
```lua
vim.keymap.set({'n', 'x', 'o'}, ';', repmove.semicolon, { expr = true })
```

### `repmove.comma()`

Executes the last motion in the backward/previous direction.

**Usage:**
```lua
vim.keymap.set({'n', 'x', 'o'}, ',', repmove.comma, { expr = true })
```

### `repmove.setup()`

Empty setup function for compatibility. No configuration needed.

**Usage:**
```lua
require('repmove').setup()
```

## Advanced Examples

### Example 1: Using with nvim-treesitter-textobjects

Wrap nvim-treesitter-textobjects motions to make them repeatable with repmove.nvim:

```lua
local repmove = require('repmove')

-- Bind ; and , first
vim.keymap.set({'n', 'x', 'o'}, ';', repmove.semicolon, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, ',', repmove.comma, { expr = true })

-- Get the textobjects motions from nvim-treesitter
local ts_move = require('nvim-treesitter.textobjects.move')

-- Wrap textobjects motions with repmove
local function goto_next_start()
  ts_move.goto_next_start('@function.outer')
end

local function goto_previous_start()
  ts_move.goto_previous_start('@function.outer')
end

local prev_func, next_func = repmove.make(goto_previous_start, goto_next_start)

vim.keymap.set({'n', 'x', 'o'}, ']f', next_func)
vim.keymap.set({'n', 'x', 'o'}, '[f', prev_func)
```

### Example 2: Multiple Repeatable Motions

```lua
local repmove = require('repmove')

-- Bind ; and , first
vim.keymap.set({'n', 'x', 'o'}, ';', repmove.semicolon, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, ',', repmove.comma, { expr = true })

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

-- Now ; and , will repeat ANY of the above motions!
```

## How It Works

The plugin works by wrapping your motion functions and tracking the last executed motion. When you press `;` or `,`, it replays the last motion in the appropriate direction.

1. You wrap your motion with `repmove.make()` 
2. The wrapper stores the forward and backward versions
3. When you execute the motion, it updates the "last motion" state
4. Pressing `;` or `,` executes the stored motion

## License

MIT License - see [LICENSE](LICENSE) for details.

