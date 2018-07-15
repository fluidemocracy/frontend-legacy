local access_token = param.get("access_token")
local client_id = param.get("client_id")
local login_url = param.get("login_url")
local format = param.get("format")

if format ~= "html" and format ~= "raw_html" then
  format = "json"
end

local items = config.meta_navigation_items_func(app.access_token and app.access_token.member or nil, client_id, login_url)

if format == "json" then
  slot.set_layout(nil, "application/json")
  local r = json.array()
  for i, item in ipairs(items) do
    r[#r+1] = json.object{
      name = item.name,
      description = item.description,
      url = item.url,
      active = item.active
    }
  end
  slot.put_into("data", json.export(json.object{ result = r }))
elseif format == "html" then
  slot.set_layout(nil, "application/json")
  local html = config.meta_navigation_style_func(items) .. config.meta_navigation_html_func(items) .. config.meta_navigation_script_func(items)
  slot.put_into("data", json.export(json.object{ result = html }))
elseif format == "raw_html" then
  slot.set_layout(nil, "text/html")
  local html = config.meta_navigation_style_func(items) .. config.meta_navigation_html_func(items) .. config.meta_navigation_script_func(items)
  slot.put_into("data", html)
end


