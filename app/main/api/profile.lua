slot.set_layout(nil, "application/json")

local r = json.object{}

if request.is_post() then
  if not app.scopes.update_profile then
    return util.api_error(403, "Forbidden", "insufficient_scope", "Scope update_profile required")
  end
  local profile = app.access_token.member.profile
  local fields = json.import(param.get("update"))
  if not fields then
    return util.api_error(400, "Bad Request", "profile_data_expected", "JSON object with updated profile data expected")
  end
  for i, field in ipairs(config.member_profile_fields) do
    if json.type(fields, field.id) ~= "nil" then
      local value = fields[field.id]
      if value ~= nil and (field.type == "string" or field.type == "text") and json.type(value) ~= "string" then
        return util.api_error(400, "Bad Request", "string_expected", "JSON encoded string value expected")
      end
      profile.profile[field.id] = value
    end
  end
  profile:save()
  r.status = 'ok'
  slot.put_into("data", json.export(r))
  slot.put_into("data", "\n")
else
  local member_id = tonumber(param.get("member_id"))
  local profile
  if member_id then
    if not app.scopes.read_profiles then
      return util.api_error(403, "Forbidden", "insufficient_scope", "Scope profile required")
    end
    local member = Member:by_id(member_id)
    if not member then
      return util.api_error(400, "Bad Request", "member_not_found", "No member with requested member_id")
    end
    profile = member.profile
  elseif app.access_token then
    if not app.scopes.profile and not app.scopes.read_profiles then
      return util.api_error(403, "Forbidden", "insufficient_scope", "Scope profile required")
    end
    profile = app.access_token.member.profile
  else
    return util.api_error(400, "Bad Request", "no_member_id", "No member_id requested")
  end
  if profile then
    r = execute.chunk{ module = "api", chunk = "_profile", params = { profile = profile } }
  end
  slot.put_into("data", json.export(json.object{ result = r }))
  slot.put_into("data", "\n")
end

