if not request.is_post() then
  return execute.view { module = "index", view = "405" }
end

slot.set_layout(nil, "application/json")

local function error_result(error_code, description)
  local r = json.object()
  r.error = error_code
  r.error_description = description
  slot.put_into("data", json.export(r))
  request.set_status("400 Bad Request")
end

local access_token, access_token_err = util.get_access_token()

if access_token_err then
  if access_token_err == "header_and_param" then
    return error_result("invalid_request", "Access token passed both via header and param")
  end
  error("Error in util.get_access_token")
end

if not access_token then
  return error_result("invalid_token", "No access token supplied")  
end

local token = Token:by_token_type_and_token("access", access_token)

if not token then
  return error_result("invalid_token", "Access token invalid")  
end

local scopes = {}
for scope in string.gmatch(token.scope, "[^ ]+") do
  local match = string.match(scope, "(.+)_detached$")
  scopes[match or scope] = true
end
local scope_list = {}
for scope in pairs(scopes) do
  scope_list[#scope_list+1] = scope
end
table.sort(scope_list)
local scope = table.concat(scope_list, " ")

local r = json.object()
r.scope = scope

local expiry = db:query({ "SELECT FLOOR(EXTRACT(EPOCH FROM ? - now())) AS access_time_left", token.expiry }, "object")
r.expires_in = expiry.access_time_left

r.member_id = token.member_id
if token.member.role then
  r.member_is_role = true
end
if token.session then
  r.real_member_id = token.session.real_member_id
end

if scopes.identification or scopes.authentication then
  if param.get("include_member", atom.boolean) then
    local member = token.member
    r.member = json.object{
      id = member.id,
      name = member.name,
    }
    if token.session and token.session.real_member then
      r.real_member = json.object{
        id = token.session.real_member.id,
        name = token.session.real_member.name,
      }
    end
    if scopes.identification then
      r.member.identification = member.identification
      if token.session and token.session.real_member then
        r.real_member.identification = token.session.real_member.identification
      end
    end
    if param.get("include_member_notify_email", atom.boolean) then
      r.member.notify_email = member.notify_email
    end
    if param.get("include_roles", atom.boolean) then
      for i, unit in ipairs(member.units) do
        if unit.attr.role then
          r.roles = json.object()
          if not unit.attr.only_visible_for_role 
            or member:has_role(unit.attr.only_visible_for_role)
          then
            r.roles[unit.attr.role] = true
          end
        end
      end
    end
  end
end

r.logged_in = token.session_id and true or false
slot.put_into("data", json.export(r))

  

