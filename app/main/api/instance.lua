local navigation

if param.get("include_navigation") then
  
  local items = config.meta_navigation_items_func(
    app.access_token and app.access_token.member or nil, 
    param.get("client_id"), 
    param.get("login_url")
  )
  
  navigation = json.array()
  for i, item in ipairs(items) do
    navigation[#navigation+1] = json.object{
      name        = item.name,
      description = item.description,
      url         = item.url,
      active      = item.active
    }
  end

end
  
local result = json.object{
  name          = config.instance_name,
  slogan        = config.meta_navigation_slogan,
  home_url      = config.meta_navigation_home_url,
  logo_url      = config.meta_navigation_logo_url,
  logo_alt_text = config.meta_navigation_logo_alt_text,
  navigation    = navigation
}

slot.set_layout(nil, "application/json")
slot.put_into("data", json.export(json.object{ result = result }))
