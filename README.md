# repmove.nvim

[English](#english) | [中文](#中文)

---

## English

### Introduction

**repmove.nvim** is a Neovim plugin that enables `;` and `,` to repeat a wide range of motions and jump actions—allowing you to replay your last navigation (not just `f`/`t`) forward or backward with consistent behavior.

### Motivation

The inspiration for this plugin came from **nvim-treesitter-textobjects**. Initially, nvim-treesitter-textobjects supported repeating movements using semicolon and comma, which provided an excellent user experience. However, a problem emerged: if you wanted to add repeat-move support for a new motion, you had to depend on nvim-treesitter-textobjects. This seemed odd because nvim-treesitter-textobjects should only be a plugin that provides textobject functionality, not something that all other plugins with movement operations should depend on.

The main issue became apparent when discovering and using **flash.nvim**. When flash.nvim's feature to bind semicolon and comma was enabled, it would hijack these keys and interfere with the repeat movement functionality. This led to the creation of this standalone plugin that can work with any jump plugin without creating unwanted dependencies.

### Features

- ✨ **Universal Repeat Movement**: Use `;` and `,` to repeat any motion, not just built-in `f`/`t`
- 🔌 **Plugin Agnostic**: Works with any jump plugin (flash.nvim, leap.nvim, hop.nvim, etc.)
- 🎯 **Simple API**: Easy-to-use `make()` function to wrap your motions
- 🚀 **Zero Dependencies**: Lightweight and standalone
- 🔄 **Bidirectional**: Automatically handles forward and backward repetition

### Installation

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

### Quick Start

#### Basic Usage (Built-in Neovim Motions)

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

#### Integration with flash.nvim

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

### API Documentation

#### `repmove.make(prev, next, comma, semicolon)`

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

#### `repmove.semicolon()`

Returns a function that repeats the last motion forward.

**Usage:**
```lua
vim.keymap.set({'n', 'x', 'o'}, ';', repmove.semicolon, { expr = true })
```

#### `repmove.comma()`

Returns a function that repeats the last motion backward.

**Usage:**
```lua
vim.keymap.set({'n', 'x', 'o'}, ',', repmove.comma, { expr = true })
```

### Advanced Examples

#### Example 1: Using with nvim-treesitter-textobjects

```lua
local repmove = require('repmove')
local ts_repeat_move = require('nvim-treesitter.textobjects.repeatable_move')

-- Make treesitter motions repeatable
local next_func, prev_func = repmove.make(
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

#### Example 2: Multiple Repeatable Motions

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

### How It Works

The plugin works by wrapping your motion functions and tracking the last executed motion. When you press `;` or `,`, it replays the last motion in the appropriate direction.

1. You wrap your motion with `repmove.make()` 
2. The wrapper stores the forward and backward versions
3. When you execute the motion, it updates the "last motion" state
4. Pressing `;` or `,` executes the stored motion

### License

MIT License - see [LICENSE](LICENSE) for details.

---

## 中文

### 简介

**repmove.nvim** 是一个 Neovim 插件，它让 `;` 和 `,` 能够重复各种移动和跳转操作——让你可以向前或向后重复上一次的导航（不仅仅是 `f`/`t`），具有一致的行为。

### 动机

这个插件的灵感来源于 **nvim-treesitter-textobjects**。最开始使用 nvim-treesitter-textobjects 时，它就支持使用分号和逗号进行重复移动，体验非常不错。但后来遇到了问题：如果需要为一个新的 motion 增加重复移动的支持，就必须依赖 nvim-treesitter-textobjects。这看起来有点奇怪，因为 nvim-treesitter-textobjects 应该只是一个提供 textobjects 功能的插件，不应该让所有其他有移动操作的插件都依赖它。

最主要的问题是后来发现了 **flash.nvim** 并开始使用它。如果开启了 flash.nvim 绑定分号和逗号的功能，这就会影响分号和逗号的重复移动（它们被 flash.nvim 劫持了）。于是创建了这个独立的插件，它可以和任何跳转插件配合使用，而不会产生不必要的依赖。

### 特性

- ✨ **通用重复移动**：使用 `;` 和 `,` 重复任何移动，不仅仅是内置的 `f`/`t`
- 🔌 **插件无关**：可以与任何跳转插件配合使用（flash.nvim、leap.nvim、hop.nvim 等）
- 🎯 **简单的 API**：易于使用的 `make()` 函数来包装你的移动操作
- 🚀 **零依赖**：轻量级且独立
- 🔄 **双向支持**：自动处理向前和向后的重复

### 安装

使用 [lazy.nvim](https://github.com/folke/lazy.nvim)：

```lua
{
  'Kaiser-Yang/repmove.nvim',
  config = function()
    -- 在这里配置
  end
}
```

使用 [packer.nvim](https://github.com/wbthomason/packer.nvim)：

```lua
use {
  'Kaiser-Yang/repmove.nvim',
  config = function()
    -- 在这里配置
  end
}
```

使用 [vim-plug](https://github.com/junegunn/vim-plug)：

```vim
Plug 'Kaiser-Yang/repmove.nvim'
```

### 快速开始

#### 基本用法（内置 Neovim 移动）

如果你不使用其他跳转插件，可以轻松包装 Neovim 内置的 `f`/`F` 移动：

```lua
local repmove = require('repmove')

-- 创建可重复的 f 和 F 版本
local prev_f, next_f = repmove.make('F', 'f', ',', ';')

-- 绑定到按键
vim.keymap.set({'n', 'x', 'o'}, 'f', next_f, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, 'F', prev_f, { expr = true })

-- 绑定 ; 和 , 来重复移动
vim.keymap.set({'n', 'x', 'o'}, ';', repmove.semicolon, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, ',', repmove.comma, { expr = true })
```

#### 与 flash.nvim 集成

以下是如何将 repmove.nvim 与 [flash.nvim](https://github.com/folke/flash.nvim) 集成：

```lua
local repmove = require('repmove')

-- 配置 flash.nvim 使用不同的按键
require('flash').setup({
  modes = {
    char = {
      enabled = true,
      keys = { "f", "F", "t", "T" },
      -- 在 flash 中不绑定 ; 和 ,
      jump_labels = false,
    },
  },
})

-- 使用 flash 的功能创建可重复版本
local prev_f, next_f = repmove.make(
  function() require('flash').jump({ forward = false, pattern = vim.fn.getcmdline() }) end,
  function() require('flash').jump({ forward = true, pattern = vim.fn.getcmdline() }) end,
  function() require('flash').jump({ forward = false, pattern = vim.fn.getcmdline() }) end,
  function() require('flash').jump({ forward = true, pattern = vim.fn.getcmdline() }) end
)

-- 或者更简单地，使用 flash 现有的按键映射
vim.keymap.set({'n', 'x', 'o'}, 'f', function()
  require('flash').jump({ forward = true })
end)
vim.keymap.set({'n', 'x', 'o'}, 'F', function()
  require('flash').jump({ forward = false })
end)

-- 绑定 ; 和 , 来重复任意移动
vim.keymap.set({'n', 'x', 'o'}, ';', repmove.semicolon, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, ',', repmove.comma, { expr = true })
```

### API 文档

#### `repmove.make(prev, next, comma, semicolon)`

创建一对支持重复移动的函数。

**参数：**
- `prev` (`function|string`)：向后移动的命令或函数
- `next` (`function|string`)：向前移动的命令或函数
- `comma` (`function|string`，可选)：按下 `,` 时执行的内容（默认为 `prev`）
- `semicolon` (`function|string`，可选)：按下 `;` 时执行的内容（默认为 `next`）

**返回值：**
- `function`：包装后的"prev"函数（用于向后移动）
- `function`：包装后的"next"函数（用于向前移动）

**示例：**
```lua
-- 简单情况：包装内置的 f 和 F
local prev_f, next_f = repmove.make('F', 'f', ',', ';')

-- 自定义函数
local prev_custom, next_custom = repmove.make(
  function() print('向后移动') end,
  function() print('向前移动') end
)
```

#### `repmove.semicolon()`

返回一个向前重复上次移动的函数。

**用法：**
```lua
vim.keymap.set({'n', 'x', 'o'}, ';', repmove.semicolon, { expr = true })
```

#### `repmove.comma()`

返回一个向后重复上次移动的函数。

**用法：**
```lua
vim.keymap.set({'n', 'x', 'o'}, ',', repmove.comma, { expr = true })
```

### 高级示例

#### 示例 1：与 nvim-treesitter-textobjects 一起使用

```lua
local repmove = require('repmove')
local ts_repeat_move = require('nvim-treesitter.textobjects.repeatable_move')

-- 使 treesitter 移动可重复
local next_func, prev_func = repmove.make(
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

#### 示例 2：多个可重复移动

```lua
local repmove = require('repmove')

-- 可重复的 f/F
local prev_f, next_f = repmove.make('F', 'f')
vim.keymap.set({'n', 'x', 'o'}, 'f', next_f, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, 'F', prev_f, { expr = true })

-- 可重复的 t/T
local prev_t, next_t = repmove.make('T', 't')
vim.keymap.set({'n', 'x', 'o'}, 't', next_t, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, 'T', prev_t, { expr = true })

-- 可重复的搜索
local prev_search, next_search = repmove.make('N', 'n')
vim.keymap.set({'n', 'x', 'o'}, 'n', next_search, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, 'N', prev_search, { expr = true })

-- 绑定 ; 和 , 来重复上述任意移动
vim.keymap.set({'n', 'x', 'o'}, ';', repmove.semicolon, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, ',', repmove.comma, { expr = true })
```

### 工作原理

该插件通过包装你的移动函数并跟踪最后执行的移动来工作。当你按下 `;` 或 `,` 时，它会以适当的方向重放最后的移动。

1. 你使用 `repmove.make()` 包装你的移动
2. 包装器存储向前和向后的版本
3. 当你执行移动时，它会更新"最后的移动"状态
4. 按下 `;` 或 `,` 会执行存储的移动

### 许可证

MIT License - 详见 [LICENSE](LICENSE)。
