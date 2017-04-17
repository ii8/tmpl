# Tiny lua templates

Demo:
```lua
local compile = require "tmpl"

local s = [[
<!DOCTYPE html>
<html>
<head>
  {! this is a comment !}
  <meta charset="utf-8">
  <title>{{page.title}}</title>
  <style>
    body {
      background-color: #{{page.bg}};
    }
  </style>
</head>
<body>
  <h3>{{escaped}}</h3>
  <h3>{* unescaped *}
  <h3>{% echo 'haHAA' %}</h3>
  {[template2]}
</body>
</html>
]]

local s2 = [[
<ul>
{% for i = 1, 3 do %}
  <li>{{i}}{{unit}}</li>
{% end %}
</ul>
{% if haHAA then %}
  {[template2, sub]}
{% end %}
]]

local template = compile(s)
local ctx = {
	page = { title = 'Demo', bg = '332233' },
	escaped = 'escaped: < &',
	unescaped = 'unescaped: &bull;</h3>',
	template2 = compile(s2),
	haHAA = true,
	unit = 'g',
	sub = {
		-- custom escape function
		escape = function(s)
			i = tonumber(s)
			if i then return i * 3 else return s end
		end,
		haHAA = false,
		unit = 'kg'
	}
}

for s in template(ctx) do
	io.write(s)
end
```
