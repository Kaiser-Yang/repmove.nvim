---@diagnostic disable: missing-parameter
local M = {}

--- @type RepMove.RepeatInfo
local last_motion = { forward = M.ensure_function(';'), backward = M.ensure_function(',') }

--- @param func function
--- @param args table
--- @return function
local function repeatable_wrap(func, args)
  return function() return func(unpack(args)) end
end

--- @param prev_func function|string
--- @param next_func function|string
--- @param is_prev boolean
--- @param backward? function|string
--- @param forward? function|string
--- @return function
local function repeat_wrap(prev_func, next_func, is_prev, backward, forward)
  prev_func = M.ensure_function(prev_func)
  next_func = M.ensure_function(next_func)
  if backward == nil then backward = is_prev and next_func or prev_func end
  if forward == nil then forward = is_prev and prev_func or next_func end
  backward = M.ensure_function(backward)
  forward = M.ensure_function(forward)
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
--- @param backward? function|string
--- @param forward? function|string
--- @return function
--- @return function
function M.make(prev, next, backward, forward)
  return repeat_wrap(prev, next, true, backward, forward), repeat_wrap(prev, next, false, backward, forward)
end

-- NOTE: We must wrap here to ensure we can get the changed "backword" and "forward"
function M.comma() return last_motion.backward() end
function M.semicolon() return last_motion.forward() end

return M
