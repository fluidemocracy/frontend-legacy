local provider = param.get("provider")
local provider_config = config.oauth2_providers[provider]
if not provider_config then
  return
end


local error = param.get("error")

if error then
  ui.heading{ content = "OAuth error" }
  ui.container{ content = error }
  return
end

local state = param.get("state")

if state ~= app.session:additional_secret_for("oauth") then
  ui.heading{ content = "OAuth error" }
  ui.container{ content = "state invalid" }
  return
end

local code = param.get("code")

local params = {
  code = code,
  client_id = provider_config.client_id,
  client_secret = provider_config.client_secret,
  redirect_uri = request.get_absolute_baseurl() .. "oauth2_client/callback.html?provider=" .. provider,
  grant_type = "authorization_code"
}

local params_list = {}
for key, val in pairs(params) do
  table.insert(params_list, encode.url_part(key) .. "=" .. encode.url_part(val))
end

local r = table.concat(params_list, "&")

local output, err, status = extos.pfilter(nil, "curl", "-X", "POST", "-d", r, provider_config.token_url)

local result = json.import(output)

local url = provider_config.id_url .. "?access_token=" .. encode.url_part(result.access_token)

local output, err, status = extos.pfilter(nil, "curl", url)

local id_result = json.import(output)

local id = id_result[provider_config.id_field]
local email = id_result[provider_config.email_field]

if id then
  local member = Member:new_selector()
    :add_where{ "authority = ?", "oauth2_" .. provider }
    :add_where{ "authority_uid = ?", id }
    :optional_object_mode()
    :exec()
    
  if not member then
    member = Member:new()
    member.authority = "oauth2_" .. provider
    member.authority_uid = id
    member.notify_email = email
    member.name = "Member " .. id
    member.identification = "Member " .. id
    member.activated = "now"
    member:save()
    for i, unit_id in ipairs(provider_config.unit_ids) do
      local privilege = Privilege:new()
      privilege.member_id = member.id
      privilege.unit_id = unit_id
      privilege.initiative_right = true
      privilege.voting_right = true
      privilege:save()
    end
  end
  member.last_login = "now"
  member.last_activity = "now"
  member.active = true
  member:save()
  app.session.member = member
  app.session:save()
  request.redirect{ external = request.get_absolute_baseurl() }
  
end

