local profile = param.get("profile", "table")

local r = json.object()

for i, field in ipairs(config.member_profile_fields) do
  if profile.profile[field.id] then
    r[field.id] = profile.profile[field.id] or json.null
  end
end
--[[
if profile.statement then
  if request.get_param{ name = "statement_format" } == "html" then
    r.statement = profile:get_content("html")
    r.statement_format = "html"
  else
    r.statement = profile.statement
    r.statement_format = profile.formatting_engine
  end
end
--]]

return r
