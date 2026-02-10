# repmove.nvim

[English](README.md) | [中文](README-zh.md)

---

## 简介

**repmove.nvim** 是一个 Neovim 插件，它让 `;` 和 `,` 能够重复各种移动和跳转操作——让你可以向前或向后重复上一次的导航（不仅仅是 `f`/`t`），具有一致的行为。

## 动机

这个插件的灵感来源于 **nvim-treesitter-textobjects**。最开始使用 nvim-treesitter-textobjects 时，它就支持使用分号和逗号进行重复移动，体验非常不错。但后来遇到了问题：如果需要为一个新的 motion 增加重复移动的支持，就必须依赖 nvim-treesitter-textobjects。这看起来有点奇怪，因为 nvim-treesitter-textobjects 应该只是一个提供 textobjects 功能的插件，不应该让所有其他有移动操作的插件都依赖它。

最主要的问题是后来发现了 **flash.nvim** 并开始使用它。如果开启了 flash.nvim 绑定分号和逗号的功能，这就会影响分号和逗号的重复移动（它们被 flash.nvim 劫持了）。于是创建了这个独立的插件，它可以和任何跳转插件配合使用，而不会产生不必要的依赖。

## 特性

- ✨ **通用重复移动**：使用 `;` 和 `,` 重复任何移动，不仅仅是内置的 `f`/`t`
- 🔌 **插件无关**：可以与任何跳转插件配合使用（flash.nvim、leap.nvim、hop.nvim 等）
- 🎯 **简单的 API**：易于使用的 `make()` 函数来包装你的移动操作
- 🚀 **零依赖**：轻量级且独立
- 🔄 **双向支持**：自动处理向前和向后的重复

## 安装

使用 [lazy.nvim](https://github.com/folke/lazy.nvim)：

```lua
{
  'Kaiser-Yang/repmove.nvim',
  opts = {}
}
```

使用 [packer.nvim](https://github.com/wbthomason/packer.nvim)：

```lua
use {
  'Kaiser-Yang/repmove.nvim',
  config = function()
    require('repmove').setup()
  end
}
```

使用 [vim-plug](https://github.com/junegunn/vim-plug)：

```vim
Plug 'Kaiser-Yang/repmove.nvim'
```

## 快速开始

### 步骤 1：绑定分号和逗号（必需）

**这是 repmove.nvim 的基石。** 你必须将 `;` 和 `,` 绑定到重复功能。虽然理论上你可以使用其他按键，但**强烈推荐使用分号和逗号**，因为它们遵循 Vim 的传统重复移动按键。

```lua
local repmove = require('repmove')

-- 绑定 ; 和 , 来重复移动
vim.keymap.set({'n', 'x', 'o'}, ';', repmove.semicolon, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, ',', repmove.comma, { expr = true })
```

设置完成后，任何使用 `repmove.make()` 包装的移动都可以使用 `;`（下一个）和 `,`（上一个）来重复。

### 步骤 2：包装你的移动

现在你可以包装任何移动来使其可重复：

#### 基本用法（内置 Neovim 移动）

如果你不使用其他跳转插件，可以轻松包装 Neovim 内置的 `f`/`F` 移动：

```lua
local repmove = require('repmove')

-- 首先绑定 ; 和 ,（必需）
vim.keymap.set({'n', 'x', 'o'}, ';', repmove.semicolon, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, ',', repmove.comma, { expr = true })

-- 创建可重复的 f 和 F 版本
local prev_f, next_f = repmove.make('F', 'f')

-- 绑定到按键
vim.keymap.set({'n', 'x', 'o'}, 'f', next_f, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, 'F', prev_f, { expr = true })
```

现在 `f` 和 `F` 可以使用 `;` 和 `,` 重复了！

#### 与 flash.nvim 集成

以下是如何将 repmove.nvim 与 [flash.nvim](https://github.com/folke/flash.nvim) 集成：

```lua
local repmove = require('repmove')

-- 首先绑定 ; 和 ,（必需）
vim.keymap.set({'n', 'x', 'o'}, ';', repmove.semicolon, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, ',', repmove.comma, { expr = true })

-- 配置 flash.nvim（不让它绑定 ; 和 ,）
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

-- 用 repmove 包装 flash 移动
local function flash_jump(forward)
  return function()
    require('flash').jump({ forward = forward })
  end
end

local prev_flash, next_flash = repmove.make(flash_jump(false), flash_jump(true))

vim.keymap.set({'n', 'x', 'o'}, 'f', next_flash, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, 'F', prev_flash, { expr = true })
```

## API 文档

### `repmove.make(prev, next, comma, semicolon)`

创建一对支持重复移动的函数。

**参数：**
- `prev` (`function|string`)：上一个移动的命令或函数（通常向后移动，例如 `F`）
- `next` (`function|string`)：下一个移动的命令或函数（通常向前移动，例如 `f`）
- `comma` (`function|string`，可选)：按下 `,` 时执行的内容（默认为 `prev`）
- `semicolon` (`function|string`，可选)：按下 `;` 时执行的内容（默认为 `next`）

**返回值：**
- `function`：包装后的 "prev" 函数
- `function`：包装后的 "next" 函数

**示例：**
```lua
-- 简单情况：包装内置的 f 和 F
local prev_f, next_f = repmove.make('F', 'f')

-- 自定义函数
local prev_custom, next_custom = repmove.make(
  function() print('跳转到上一个') end,
  function() print('跳转到下一个') end
)
```

### `repmove.semicolon()`

执行上一次移动的下一个方向。

**用法：**
```lua
vim.keymap.set({'n', 'x', 'o'}, ';', repmove.semicolon, { expr = true })
```

### `repmove.comma()`

执行上一次移动的上一个方向。

**用法：**
```lua
vim.keymap.set({'n', 'x', 'o'}, ',', repmove.comma, { expr = true })
```

### `repmove.setup()`

空的设置函数，用于兼容性。无需配置。

**用法：**
```lua
require('repmove').setup()
```

## 高级示例

### 示例 1：与 nvim-treesitter-textobjects 一起使用

用 repmove.nvim 包装 nvim-treesitter-textobjects 的移动来使其可重复：

```lua
local repmove = require('repmove')

-- 首先绑定 ; 和 ,
vim.keymap.set({'n', 'x', 'o'}, ';', repmove.semicolon, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, ',', repmove.comma, { expr = true })

-- 从 nvim-treesitter 获取 textobjects 移动
local ts_move = require('nvim-treesitter.textobjects.move')

-- 用 repmove 包装 textobjects 移动
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

### 示例 2：多个可重复移动

```lua
local repmove = require('repmove')

-- 首先绑定 ; 和 ,
vim.keymap.set({'n', 'x', 'o'}, ';', repmove.semicolon, { expr = true })
vim.keymap.set({'n', 'x', 'o'}, ',', repmove.comma, { expr = true })

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

-- 现在 ; 和 , 可以重复上述任意移动！
```

## 工作原理

该插件通过包装你的移动函数并跟踪最后执行的移动来工作。当你按下 `;` 或 `,` 时，它会以适当的方向重放最后的移动。

1. 你使用 `repmove.make()` 包装你的移动
2. 包装器存储向前和向后的版本
3. 当你执行移动时，它会更新"最后的移动"状态
4. 按下 `;` 或 `,` 会执行存储的移动

## 许可证

MIT License - 详见 [LICENSE](LICENSE)。
