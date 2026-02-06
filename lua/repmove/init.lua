---@diagnostic disable: missing-parameter
local M = {}

--- @param value any
--- @return function
local function ensure_function(value)
  if type(value) == 'function' then return value end
  return function() return value end
end

--- @type RepMove.RepeatInfo
local last_motion = { forward = ensure_function(';'), backward = ensure_function(',') }

--- @param func function
--- @param args table
--- @return function
local function repeatable_wrap(func, args)
  return function() return func(unpack(args)) end
end

--- @param prev_func function|string
--- @param next_func function|string
--- @param is_prev boolean
--- @param backward function|string
--- @param forward function|string
--- @return function
local function repeat_wrap(prev_func, next_func, is_prev, backward, forward)
  prev_func = ensure_function(prev_func)
  next_func = ensure_function(next_func)
  backward = ensure_function(backward)
  forward = ensure_function(forward)
  return function(...)
    local args = { ... }
    last_motion.forward = repeatable_wrap(forward, args)
    last_motion.backward = repeatable_wrap(backward, args)
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
--- @param comma? function|string
--- @param semicolon? function|string
--- @return function
--- @return function
function M.make(prev, next, comma, semicolon)
  comma = comma or prev
  semicolon = semicolon or next
  return repeat_wrap(prev, next, true, comma, semicolon), repeat_wrap(prev, next, false, comma, semicolon)
end

-- NOTE: We must wrap here to ensure we can get the changed "backword" and "forward"
function M.comma() return last_motion.backward() end
function M.semicolon() return last_motion.forward() end

--- Setup function (no-op, for compatibility)
function M.setup() end

return M
