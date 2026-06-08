---@diagnostic disable: missing-parameter
local u = require('repmove.util')
local M = {}

---@type RepMove.LastMotion
local last_motion = {
  global = { forward = u.ensure_function(';'), backward = u.ensure_function(',') },
  filetype = {},
}

--- @param func function
--- @param args table
--- @return function
local function repeatable_wrap(func, args)
  return function() return func(unpack(args)) end
end

--- @param direction 'forward'|'backward'
--- @return function
local function get_repeat(direction)
  local filetype = vim.bo.filetype
  local repeat_store = last_motion.filetype[filetype]
  if repeat_store then return repeat_store[direction] end
  return last_motion.global[direction]
end

--- @param filetypes? string|string[]
--- @return string[]|nil
local function normalize_filetypes(filetypes)
  filetypes = u.unique(u.ensure_list(filetypes))
  if #filetypes == 0 then return nil end
  return filetypes
end

--- @param forward function
--- @param backward function
--- @param filetypes? string[]
local function set_last_motion(forward, backward, filetypes)
  local repeat_store = { forward = forward, backward = backward }
  if filetypes == nil then
    last_motion.global = repeat_store
    last_motion.filetype = {}
    return
  end
  for _, filetype in ipairs(filetypes) do
    last_motion.filetype[filetype] = repeat_store
  end
end

--- @param prev_func function|string
--- @param next_func function|string
--- @param is_prev boolean
--- @param backward? function|string
--- @param forward? function|string
--- @param filetypes? string[]
--- @return function
local function repeat_wrap(prev_func, next_func, is_prev, backward, forward, filetypes)
  prev_func = u.ensure_function(prev_func)
  next_func = u.ensure_function(next_func)
  if backward == nil then backward = is_prev and next_func or prev_func end
  if forward == nil then forward = is_prev and prev_func or next_func end
  backward = u.ensure_function(backward)
  forward = u.ensure_function(forward)
  return function(...)
    local args = { ... }
    set_last_motion(repeatable_wrap(forward, args), repeatable_wrap(backward, args), filetypes)
    if is_prev then
      return prev_func(...)
    else
      return next_func(...)
    end
  end
end

--- Wrap two repeatable actions.
--- @param prev function|string
--- @param next function|string
--- @param backward? function|string
--- @param forward? function|string
--- @param filetypes? string|string[]
--- @return function
--- @return function
function M.make(prev, next, backward, forward, filetypes)
  filetypes = normalize_filetypes(filetypes)
  return repeat_wrap(prev, next, true, backward, forward, filetypes),
    repeat_wrap(prev, next, false, backward, forward, filetypes)
end

function M.comma() return get_repeat('backward')() end
function M.semicolon() return get_repeat('forward')() end

return M
