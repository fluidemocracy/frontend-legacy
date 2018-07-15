slot.set_layout(nil, "application/json")

if not app.access_token then
  return util.api_error(400, "Forbidden", "insufficient_scope", "Scope 'settings' required")
end

local r = json.object{}

if request.is_post() then
  if not app.scopes.update_settings then
    return util.api_error(403, "Forbidden", "insufficient_scope", "Scope update_settings required")
  end
  local settings = app.access_token.member.settings
  if not settings then
    settings = MemberSettings:new()
    settings.member_id = app.access_token.member_id
    settings.settings = json.object()
  end
  local fields = json.import(param.get("update"))
  if not fields then
    return util.api_error(400, "Bad Request", "settings_data_expected", "JSON object with updated settings data expected")
  end
  for i, field in ipairs(config.member_settings_fields) do
    if json.type(fields, field.id) ~= "nil" then
      local value = fields[field.id]
      if value ~= nil then
        if (field.type == "string" or field.type == "text") and json.type(value) ~= "string" then
          return util.api_error(400, "Bad Request", "string_expected", "JSON encoded string value expected")
        end
        if (field.type == "boolean") and json.type(value) ~= "boolean" then
          return util.api_error(400, "Bad Request", "boolean_expected", "JSON encoded boolean value expected")
        end
      end
      settings.settings[field.id] = value
    end
  end
  settings:save()
  r.status = 'ok'
  slot.put_into("data", json.export(r))
  slot.put_into("data", "\n")
else
  if not app.scopes.settings then
    return util.api_error(403, "Forbidden", "insufficient_scope", "Scope 'settings' required")
  end
  local settings = app.access_token.member.settings or json.object()
  r = execute.chunk{ module = "api", chunk = "_settings", params = { settings = settings } }
  slot.put_into("data", json.export(json.object{ result = r }))
  slot.put_into("data", "\n")
end

