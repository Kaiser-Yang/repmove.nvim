# repmove.nvim

一个让 `;` 和 `,` 可以重复各种移动和跳转动作的 Neovim 插件——这样你就可以用一致的方式向前或向后重复你的上一次导航操作（不仅仅是 f/t）。

[English Documentation](README.md)

## ✨ 动机

我写这个插件的灵感来源于 [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects)。我最开始使用 nvim-treesitter-textobjects 的时候，它就支持使用分号（`;`）和逗号（`,`）进行重复移动，我觉得体验非常不错。

但是后来我遇到了问题：如果我需要为一个新的 motion 增加重复移动的支持，我必须得依赖 nvim-treesitter-textobjects。这看上去有点怪，因为 nvim-treesitter-textobjects 只应该是一个提供 textobjects 功能的插件，而不应该让所有其他有移动操作的插件都依赖它。

最主要的原因是我后面发现了 [flash.nvim](https://github.com/folke/flash.nvim) 并开始使用它，我现在已经重度依赖这个插件进行跳转。如果我开启了 flash.nvim 的绑定分号和逗号的功能，这就会影响分号和逗号的重复移动（它们被 flash.nvim 劫持了）。于是我当时就自己重新写了一个简单的 repmove 的模块在我的 dotfiles 里面。

但是后面我发现应该会有很多人会同时使用 nvim-treesitter-textobjects 和 flash.nvim（或者其他的跳转插件），它们都会在使用分号和逗号进行重复移动的时候遇到问题。于是有了这个插件。它理论上可以和任何的跳转插件结合，并提供一致的重复移动接口。

## 📦 安装

### 使用 [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "Kaiser-Yang/repmove.nvim",
  config = function()
    -- 请参考下面的配置部分
  end,
}
```

### 使用 [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'Kaiser-Yang/repmove.nvim',
  config = function()
    -- 请参考下面的配置部分
  end
}
```

### 使用 [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'Kaiser-Yang/repmove.nvim'
```

## 🚀 快速开始

### 默认使用（不使用其他跳转插件）

如果你不使用其他跳转插件，只想为默认的 `f`、`F`、`t`、`T` 移动添加重复移动支持：

```lua
local repmove = require('repmove')

-- 为 f 和 F 创建可重复的版本
local f_forward, f_backward = repmove.make('F', 'f', ',', ';')

-- 绑定到按键
vim.keymap.set({ 'n', 'x', 'o' }, 'f', f_forward, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'F', f_backward, { expr = true })

-- 绑定逗号和分号用于重复移动
vim.keymap.set({ 'n', 'x', 'o' }, ';', repmove.semicolon, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, ',', repmove.comma, { expr = true })
```

### 与 flash.nvim 一起使用

如果你使用 flash.nvim 或类似的跳转插件，你需要：

1. 将 flash.nvim 的功能绑定到其他按键（例如 `<Plug>` 映射）
2. 使用 repmove.nvim 创建可重复的版本
3. 将 `;` 和 `,` 绑定到 repmove 的重复函数

```lua
local repmove = require('repmove')
local flash = require('flash')

-- 首先，为 flash 函数创建 Plug 风格的映射
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

-- 创建可重复的版本
local f_forward, f_backward = repmove.make(
  '<Plug>(flash-F)',  -- prev: 向后搜索
  '<Plug>(flash-f)',  -- next: 向前搜索
  '<Plug>(flash-F)',  -- 按下逗号时调用（向后）
  '<Plug>(flash-f)'   -- 按下分号时调用（向前）
)

local t_forward, t_backward = repmove.make(
  '<Plug>(flash-T)',
  '<Plug>(flash-t)',
  '<Plug>(flash-T)',
  '<Plug>(flash-t)'
)

-- 绑定到按键
vim.keymap.set({ 'n', 'x', 'o' }, 'f', f_forward, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'F', f_backward, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 't', t_forward, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'T', t_backward, { expr = true })

-- 绑定逗号和分号用于重复移动
vim.keymap.set({ 'n', 'x', 'o' }, ';', repmove.semicolon, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, ',', repmove.comma, { expr = true })
```

## 📖 API 文档

### `repmove.make(prev, next, comma, semicolon)`

创建一对可重复的移动函数。

**参数：**
- `prev` (function|string): 向后移动的函数或按键映射
- `next` (function|string): 向前移动的函数或按键映射
- `comma` (function|string, 可选): 按下 `,` 时调用的函数（默认为 `prev`）
- `semicolon` (function|string, 可选): 按下 `;` 时调用的函数（默认为 `next`）

**返回值：**
- `function`: 向后移动的包装函数（应绑定到你的向后按键，例如 `F`）
- `function`: 向前移动的包装函数（应绑定到你的向前按键，例如 `f`）

**示例：**
```lua
-- 简单用法
local backward_motion, forward_motion = repmove.make('F', 'f')

-- 自定义重复行为
local backward_motion, forward_motion = repmove.make('F', 'f', ',', ';')

-- 与 flash.nvim 一起使用
local backward_motion, forward_motion = repmove.make(
  '<Plug>(flash-F)',
  '<Plug>(flash-f)',
  '<Plug>(flash-F)',
  '<Plug>(flash-f)'
)
```

### `repmove.semicolon()`

向前重复上一次的移动。这应该绑定到 `;` 键。

**返回值：**
- 调用上一次向前移动的结果

**示例：**
```lua
vim.keymap.set({ 'n', 'x', 'o' }, ';', repmove.semicolon, { expr = true })
```

### `repmove.comma()`

向后重复上一次的移动。这应该绑定到 `,` 键。

**返回值：**
- 调用上一次向后移动的结果

**示例：**
```lua
vim.keymap.set({ 'n', 'x', 'o' }, ',', repmove.comma, { expr = true })
```

## 🔧 高级配置

### 与 nvim-treesitter-textobjects 一起使用

```lua
local repmove = require('repmove')
local ts_repeat_move = require('nvim-treesitter.textobjects.repeatable_move')

-- 创建 treesitter textobject 移动的可重复版本
local next_func, prev_func = repmove.make(
  ts_repeat_move.builtin_F,
  ts_repeat_move.builtin_f,
  ts_repeat_move.builtin_F,
  ts_repeat_move.builtin_f
)

vim.keymap.set({ 'n', 'x', 'o' }, 'f', next_func, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'F', prev_func, { expr = true })

-- 绑定逗号和分号
vim.keymap.set({ 'n', 'x', 'o' }, ';', repmove.semicolon, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, ',', repmove.comma, { expr = true })
```

### 自定义移动函数

你也可以包装自定义的 Lua 函数：

```lua
local repmove = require('repmove')

-- 自定义移动函数
local function my_forward_search()
  -- 你的自定义搜索逻辑
  vim.fn.search('pattern', 'W')
end

local function my_backward_search()
  -- 你的自定义搜索逻辑
  vim.fn.search('pattern', 'bW')
end

-- 让它们可重复
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

## 💡 工作原理

这个插件通过包装你的移动函数并存储上一次使用的移动来工作。当你按下 `;` 或 `,` 时，它会在适当的方向上重放上一次的移动。

关键点在于 `repmove.make()` 返回的**包装函数**会：
1. 在执行时将移动存储为"上次使用的移动"
2. 执行原始移动函数
3. 将结果返回给 Neovim

当你按下 `;` 或 `,` 时，`repmove.semicolon()` 或 `repmove.comma()` 只是简单地调用存储的向前或向后移动函数。

## 🤝 贡献

欢迎贡献！请随时提交 Pull Request。

## 📝 许可证

该项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) - 最初的灵感来源
- [flash.nvim](https://github.com/folke/flash.nvim) - 出色的跳转插件，促使了这个插件的创建
