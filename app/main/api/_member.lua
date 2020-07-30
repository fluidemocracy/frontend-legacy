local members = param.get("members", "table")

local include_unit_ids = param.get("include_unit_ids", atom.boolean)
local include_units = param.get("include_units", atom.boolean)
local include_roles = param.get("include_roles", atom.boolean)
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

  if include_unit_ids or include_units or include_roles then
    members:load("units")
  end

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
    if include_unit_ids or include_units or include_roles then
      if include_unit_ids then
        m.unit_ids = json.array()
      end
      if include_units then
        m.units = json.array()
      end
      if include_roles then
        m.roles = json.object()
      end
      for i, unit in ipairs(member.units) do
        if unit.attr.hidden ~= true then
          if include_unit_ids then
            table.insert(m.unit_ids, unit.id)
          end
          if include_units then
            table.insert(m.units, json.object{
              id = unit.id,
              parent_id = unit.parent_id,
              name = unit.name,
              description = unit.description
            })
          end
        end
        if include_roles then
          if unit.attr.role then
            if not unit.attr.only_visible_for_role 
              or app.access_token
              and app.access_token.member:has_role(unit.attr.only_visible_for_role)
            then
              m.roles[unit.attr.role] = true
            end
          end
        end
      end
    end
    if include_profile then
      m.profile = execute.chunk{ module = "api", chunk = "_profile", params = { profile = member.profile } }
    end
    r[#r+1] = m
  end
end

return r
