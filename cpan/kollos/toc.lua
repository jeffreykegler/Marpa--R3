#!lua

--[[
# Table of contents
# one
## one two
### one two 3
]]

local hrefs = {}

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
  href = href:gsub('^[-]+', '')
  href = href:gsub('[-]+$', '')
  do
    local href_id = hrefs[href]
    if not href_id then
      hrefs[href] = ''
      goto HREF_FOUND
    end
    local base = href
    if href_id ~= '' then
         base = string.sub(href, 1, -(2+#href_id))
    end
    local id_num = math.tointeger(href_id)
    if not id_num then id_num = 0 end
    while true do
      local new_href_id = tostring(id_num+1)
      local new_href = base .. '-' .. new_href_id
      if not hrefs[new_href] then
	 hrefs[new_href] = new_href_id
	 href = new_href
	 goto HREF_FOUND
      end
      id_num = id_num + 1
    end
  end
  ::HREF_FOUND::
  io.stdout:write(string.format('%s* [%s](#%s)\n', string.rep('  ', depth-2), title, href))
  ::NEXT_LINE::
end

