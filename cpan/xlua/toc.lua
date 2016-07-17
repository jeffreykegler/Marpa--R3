#!lua

--[[
# Table of contents
# one
## one two
### one two 3
]]

while true do
  local line = io.stdin:read()
  if not line then break end
  if not line:match('^#') then goto NEXT_LINE end
  local title, depth = line:gsub('#', '')
  if depth <= 1 then goto NEXT_LINE end
  title = title:gsub('^ *', '')
  title = title:gsub(' *$', '')
  lowered = title:lower()
  local href = lowered:gsub('[%s%c%p]+', '-')
  io.stdout:write(string.format('%s* [%s](#%s)\n', string.rep('  ', depth-2), title, href))
  ::NEXT_LINE::
end

