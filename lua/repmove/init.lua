---@diagnostic disable: missing-parameter
local M = {}

--- @param value string
--- @return function
local function value_wrap(value)
  return function() return value end
end

--- @type RepMove.RepeatInfo
local last_motion = {}

--- @param func function
--- @param args table
--- @return function|nil
local function get_repeatable_function(func, args)
  return function() return func(unpack(args)) end
end

--- @generic T1 function
--- @generic T2 function
--- @param prev_func T1|string
--- @param next_func T2|string
--- @param is_prev boolean
--- @return T1|T2|fun():string
local function repeat_wrap(prev_func, next_func, is_prev)
  if type(prev_func) == 'string' then prev_func = value_wrap(prev_func) end
  if type(next_func) == 'string' then next_func = value_wrap(next_func) end
  return function(...)
    local args = { ... }
    last_motion.prev = get_repeatable_function(is_prev and next_func or prev_func, args)
    last_motion.next = get_repeatable_function(is_prev and prev_func or next_func, args)
    if is_prev then
      return prev_func(...)
    else
      return next_func(...)
    end
  end
end

--- Wrap two repeatable actions.
--- When `prev_func`/`next_func` are strings, returns functions that produce the keys to feed.
--- @generic TPrev: function
--- @generic TNext: function
--- @param prev_func TPrev|string
--- @param next_func TNext|string
--- @return TPrev|fun(): string
--- @return TNext|fun(): string
function M.make(prev_func, next_func)
  return repeat_wrap(prev_func, next_func, true), repeat_wrap(prev_func, next_func, false)
end

function M.builtin_f()
  last_motion.prev, last_motion.next = nil, nil
  return 'f'
end

function M.builtin_F()
  last_motion.prev, last_motion.next = nil, nil
  return 'F'
end

function M.builtin_t()
  last_motion.prev, last_motion.next = nil, nil
  return 't'
end

function M.builtin_T()
  last_motion.prev, last_motion.next = nil, nil
  return 'T'
end

--- @return any
function M.comma()
  if last_motion.prev then
    return last_motion.prev()
  else
    return ','
  end
end

--- @return any
function M.semicolon()
  if last_motion.next then
    return last_motion.next()
  else
    return ';'
  end
end

return M
