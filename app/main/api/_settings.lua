local settings = param.get("settings", "table")

local r = json.object()

for i, field in ipairs(config.member_settings_fields) do
  if settings.settings[field.id] ~= nil then
    r[field.id] = settings.settings[field.id]
  end
end

return r
