return function(str)
	local t = {[[
local ctx = ...
local function _____()
local _ENV = setmetatable(ctx, { __index = _ENV })
local function echo(s) if s ~= '' then coroutine.yield(s) end end
local function include(template, ctx)
	if ctx then
		ctx.escape = ctx.escape or _ENV.escape
	else
		ctx = _ENV
	end
	for s in template(ctx) do coroutine.yield(s) end
end
_ENV.escape = escape or function(i)
	return tostring(i or ''):gsub('[&<>"\'/]', {
		['&'] = '&amp;',
		['<'] = '&lt;',
		['>'] = '&gt;',
		['"'] = '&quot;',
		["'"] = '&#39;',
		['/'] = '&#47;'
	})
end
]]	}

	local function f(pos)
		local start, stop, c = pos - 1
		repeat
			start, stop = str:find('%b{}', start + 1)
			if not start then
				table.insert(t, ' echo([=====[\n')
				table.insert(t, str:sub(pos, #str))
				table.insert(t, ']=====]) ')
				return
			end
			c = str:sub(start + 1, start + 1)
		until c:match('[{%*%[%%!]')

		table.insert(t, ' echo([=====[\n')
		table.insert(t, str:sub(pos, start - 1))
		table.insert(t, ']=====]) ')

		if c == '{' then
			table.insert(t, ' echo(escape(')
			table.insert(t, str:sub(start + 2, stop - 2))
			table.insert(t, ')) ')
		elseif c == '*' then
			table.insert(t, ' echo(')
			table.insert(t, str:sub(start + 2, stop - 2))
			table.insert(t, ') ')
		elseif c == '[' then
			table.insert(t, ' include(')
			table.insert(t, str:sub(start + 2, stop - 2))
			table.insert(t, ') ')
		elseif c == '%' then
			table.insert(t, str:sub(start + 2, stop - 2))
		end
		f(stop + 1)
	end
	f(1)

	table.insert(t, [[ end return coroutine.wrap(_____) ]])
	return load(table.concat(t))
end
