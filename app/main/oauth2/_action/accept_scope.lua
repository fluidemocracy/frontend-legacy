local system_application_id = param.get("system_application_id", atom.integer)
local domain = param.get("domain")
local response_type = param.get("response_type")

if domain then
  domain = string.lower(domain)
end
local scopes = {}
for i = 0, math.huge do
  scopes[i] = param.get("scope" .. i)
  if not scopes[i] then
    break
  end
end

local redirect_uri = param.get("redirect_uri")
local redirect_uri_explicit = param.get("redirect_uri_explicit", atom.boolean)
local state = param.get("state")

local selector

if system_application_id then
  selector = MemberApplication:get_selector_by_member_id_and_system_application_id(app.session.member_id, system_application_id)
else
  selector = MemberApplication:get_selector_by_member_id_and_domain(app.session.member_id, domain)
end
selector:for_update()

local member_application = selector:exec()

if not member_application then
  member_application = MemberApplication:new()
  member_application.member_id = app.session.member_id
  member_application.system_application_id = system_application_id
  member_application.domain = domain
end

local new_scopes = {}

for i = 0, #scopes do
  if scopes[i] then
    for scope in string.gmatch(scopes[i], "[^ ]+") do
      new_scopes[scope] = true
    end
  end
end

if member_application.scopes then
  for scope in string.gmatch(member_application.scopes, "[^ ]+") do
    new_scopes[scope] = true
  end
end

local new_scopes_list = {}

for k, v in pairs(new_scopes) do
  new_scopes_list[#new_scopes_list+1] = k
end

local new_scopes_string = table.concat(new_scopes_list, " ")

member_application.scope = new_scopes_string

member_application:save()

execute.chunk{ module = "oauth2", chunk = "_authorization", params = {
  member_id = app.session.member_id, 
  system_application_id = system_application_id,
  domain = domain, 
  session_id = app.session.id, 
  redirect_uri = redirect_uri, 
  redirect_uri_explicit = redirect_uri_explicit, 
  scopes = scopes, 
  state = state,
  response_type = response_type
} }
