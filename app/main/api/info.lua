slot.set_layout(nil, "application/json")

local scope_string

local scopes_list = {}
for scope in pairs(app.scopes) do
  scopes_list[#scopes_list+1] = scope
end
local scopes_string = table.concat(scopes_list, " ")

local result = {}

local r = json.object{
    service = "LiquidFeedback",
    core_version = db:query("SELECT * from liquid_feedback_version;")[1].string,
    api_version = config.app_version,
    client_tls_dn = request.get_header("X-SSL-DN"),
    scope = scopes_string
}

if app.scopes.identification or app.scopes.authentication then
  r.member_id = app.access_token.member_id
  if app.access_token.member.role then
    r.member_is_role = true
  end
  if app.access_token.session then
    r.real_member_id = app.access_token.session.real_member_id
  end
  if param.get("include_member", atom.boolean) then
    local member = app.access_token.member
    result.member = json.object{
      id = member.id,
      name = member.name
    }
    if app.access_token.session and app.access_token.session.real_member then
      result.real_member = json.object{
        id = app.access_token.session.real_member.id,
        name = app.access_token.session.real_member.name,
      }
    end
    if app.scopes.identification then
      result.member.identification = member.identification
      if app.access_token.session and app.access_token.session.real_member then
        result.real_member.identification = app.access_token.session.real_member.identification
      end
    end
  end
end

result.result = r

slot.put_into("data", json.export(result))
slot.put_into("data", "\n")
