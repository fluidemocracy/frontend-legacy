slot.set_layout(nil, "application/json")

local r = json.object{
  result = json.array()
}

local selector = Member:new_selector()
  :add_where("activated NOTNULL")
  :add_order_by("id")

local id = param.get("id")
if id then
  local ids = { sep = ", " }
  for match in string.gmatch(id, "[^,]+") do
    table.insert(ids, { "?", match })
  end
  selector:add_where{ "id IN ($)", ids }
end

local role = param.get("role")
if role then
  local units = Unit:new_selector()
    :add_where{ "attr->>'role' = ?", role }
    :exec()
  if #units ~= 1 then
    request.set_status("400 Bad Request")
    slot.put_into("data", json.export{ 
      error = "invalid_role",
      error_description = "role not available"
    })
    return
  end
  local unit = units[1]
  if unit.attr.only_visible_for_role 
    and (
      not app.access_token 
      or not app.access_token.member:has_role(unit.attr.only_visible_for_role)
    )
  then
    request.set_status("400 Bad Request")
    slot.put_into("data", json.export{ 
      error = "no_priv",
      error_description = "no privileges to access this role"
    })
    return
  end
  selector:join("privilege", nil, "privilege.member_id = member.id")
  selector:join("unit", nil, { "unit.id = privilege.unit_id AND unit.attr->>'role' = ?", role })
end

local search = param.get("q")
if app.scopes.read_identities and search then
  search = "%" .. search .. "%"
  selector:add_where{ "name ILIKE ? OR identification ILIKE ?", search, search }
end

local members = selector:exec()
local r = json.object()
r.result = execute.chunk{ module = "api", chunk = "_member", params = { 
  members = members,
  include_unit_ids = param.get("include_unit_ids") and true or false,
  include_units = param.get("include_units") and true or false,
  include_roles = param.get("include_roles") and true or false
} } 


slot.put_into("data", json.export(r))
slot.put_into("data", "\n")
