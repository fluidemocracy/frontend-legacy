local member_id = param.get("member_id", atom.integer)
local system_application_id = param.get("system_application_id", atom.integer)
local domain = param.get("domain")
local session_id = param.get("session_id", atom.integer)
local redirect_uri = param.get("redirect_uri")
local redirect_uri_explicit = param.get("redirect_uri_explicit", atom.boolean)
local scopes = param.get("scopes", "table")
local state = param.get("state")
local response_type = param.get("response_type")

if response_type == "code" then

  local token = Token:create_authorization(
    member_id,
    system_application_id,
    domain,
    session_id,
    redirect_uri,
    redirect_uri_explicit,
    scopes,
    state
  )

  request.redirect{ 
    external = redirect_uri,
    params = { code = token.token, state = state }
  }

  
elseif response_type == "token" then
  
  local expiry = db:query({ "SELECT now() + (? || 'sec')::interval AS access", config.oauth2.access_token_lifetime }, "object").access

  local anchor_params = {
    state = state,
    expires_in = config.oauth2.access_token_lifetime,
    token_type = "bearer"
  }
  
  for i = 0, #scopes do
    if scopes[i] then
      local access_token = Token:new()
      access_token.token_type = "access"
      access_token.member_id = member_id
      access_token.system_application_id = system_application_id
      access_token.domain = domain
      access_token.session_id = session_id
      access_token.expiry = expiry
      access_token.scope = scopes[i]
      access_token:save()
      local index = i == 0 and "" or i 
      anchor_params["access_token" .. index] = access_token.token
    end
  end

  local anchor_params_list = {}
  for k, v in pairs(anchor_params) do
    anchor_params_list[#anchor_params_list+1] = k .. "=" .. encode.url_part(v)
  end
  local anchor = table.concat(anchor_params_list, "&")

  request.redirect{ 
    external = redirect_uri .. "#" .. anchor
  }
  
else
  
  error("Internal error, should not happen")
  
end
