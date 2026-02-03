local M = {}

--- @generic T any
--- @param t T[]
--- @return T[]
function M.unique(t)
	local res, h = {}, {}
	for _, v in ipairs(t) do
		if not h[v] then
			table.insert(res, v)
			h[v] = true
		end
	end
	return res
end

--- @generic T any
--- @param value T|T[]
--- @return T[]
function M.ensure_list(value)
	if type(value) == "table" then
		return value
	elseif type(value) == "string" or type(value) == "function" then
		return { value }
	elseif not value then
		return {}
	else
		vim.notify("Expected a table or string, got: " .. type(value), vim.log.levels.ERROR)
		return {}
	end
end

return M
