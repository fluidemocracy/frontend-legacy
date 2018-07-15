local members = param.get("members", "table")

local include_profile = param.get("include_profile", atom.boolean)

if include_profile and not app.scopes.read_profiles then
  return util.api_error(403, "Forbidden", "insufficient_scope", "Scope read_profiles required")
end

local fields = {}

if app.scopes.read_authors or app.scopes.read_identities then
  fields = { "id", "created", "last_activity", "admin", "name", "location" }
end

if app.scopes.read_identities then
  fields[#fields+1] = "identification"
end

local r = json.array()

if app.scopes.read_identities then
  
  if include_profile then
    members:load("profile")
  end

  for i, member in ipairs(members) do
    local m = json.object()
    for j, field in ipairs(fields) do
      local value = member[field]
      if value == nil then
        value = json.null
      else
        value = tostring(value)
      end
      m[field] = value
    end
    if include_profile then
      m.profile = execute.chunk{ module = "api", chunk = "_profile", params = { profile = member.profile } }
    end
    r[#r+1] = m
  end
end

return r
