if not request.is_post() then
  return execute.view { module = "index", view = "405" }
end

slot.set_layout(nil, "application/json;charset=UTF-8")

request.add_header("Cache-Control", "no-store")
request.add_header("Pragma", "no-cache")

local function error_result(error_code, error_description)
  -- TODO special HTTP status codes for some errors?
  request.set_status("400 Bad Request")
  slot.put_into("data", json.export{ 
    error = error_code,
    error_description = error_description
  })
end

local token
local grant_type = param.get("grant_type")
if grant_type == "authorization_code" then
  local code = param.get("code")
  token = Token:by_token_type_and_token("authorization", code)
elseif grant_type == "refresh_token" then
  local refresh_token = param.get("refresh_token")
  token = Token:by_token_type_and_token("refresh", refresh_token)
elseif grant_type == "access_token" then
  local access_token, access_token_err = util.get_access_token()
  if access_token_err then
    if access_token_err == "header_and_param" then
      return error_result("invalid_request", "Access token passed both via header and param")
    end
    error("Error in util.get_access_token")
  end
  token = Token:by_token_type_and_token("access", access_token)
else
  return error_result("unsupported_grant_type", "Grant type not supported")
end

if not token then
  return error_result("invalid_grant", "Token invalid or expired")
end

if grant_type == "authorization_code" then
  if not token.used then
    local expiry = db:query({"SELECT now() + (? || 'sec')::interval AS expiry", config.oauth2.authorization_code_lifetime }, "object").expiry
    token.used = true
    token.expiry = expiry
    token:save()
  else
    token:destroy()
    return error_result("invalid_grant", "Token invalid or expired")
  end
end

if grant_type ~= "access_token" then
  local cert_ca = request.get_header("X-LiquidFeedback-CA")
  local cert_distinguished_name = request.get_header("X-SSL-DN")
  local cert_common_name

  if not token.system_application or token.system_application.cert_common_name then
    if cert_distinguished_name then
      cert_common_name = string.match(cert_distinguished_name, "%f[^/\0]CN=([A-Za-z0-9_.-]+)%f[/\0]")
      if not cert_common_name then
        return error_result("invalid_client", "CN in X.509 certificate invalid")
      end
    else
      return error_result("invalid_client", "X.509 client authorization missing")
    end
  end
  if token.system_application then
    if token.system_application.cert_common_name then
      if cert_ca ~= "private" then
        return error_result("invalid_client", "X.509 certificate not signed by private certificate authority or wrong endpoint used")
      end
      if cert_common_name ~= token.system_application.cert_common_name then
        return error_result("invalid_grant", "CN in X.509 certificate incorrect")
      end
    end
  else
    if cert_ca ~= "public" then
      return error_result("invalid_client", "X.509 certificate not signed by publicly trusted certificate authority or wrong endpoint used")
    end
    if cert_common_name ~= token.domain then
      return error_result("invalid_grant", "CN in X.509 certificate incorrect")
    end
  end
  local client_id = param.get("client_id")
  if client_id then
    if token.system_application then
      if client_id ~= token.system_application.client_id then
        return error_result("invalid_grant", "Token was issued to another client")
      end
    else
      if client_id ~= "dynamic:" .. token.domain then
        return error_result ("invalid_grant", "Token was issued to another client")
      end
    end
  elseif grant_type == "authorization_code" and not cert_common_name then
    return error_result("invalid_request", "No client_id supplied for authorization_code request")
  end
end

if grant_type == "authorization_code" then
  local redirect_uri = param.get("redirect_uri")
  if (token.redirect_uri_explicit or redirect_uri) and token.redirect_uri ~= redirect_uri then
    return error_result("invalid_request", "Redirect URI missing or invalid")
  end
end

local scopes = {
  [0] = param.get("scope")
}
for i = 1, math.huge do
  scopes[i] = param.get("scope" .. i)
  if not scopes[i] then
    break
  end
end

if not scopes[0] and #scopes == 0 then
  for dummy, token_scope in ipairs(token.token_scopes) do
    scopes[token_scope.index] = token_scope.scope
  end
end

local allowed_scopes = {}
local requested_detached_scopes = {}
for scope in string.gmatch(token.scope, "[^ ]+") do
  allowed_scopes[scope] = true
end
for i = 0, #scopes do
  if scopes[i] then
    for scope in string.gmatch(scopes[i], "[^ ]+") do
      if string.match(scope, "_detached$") then
        requested_detached_scopes[scope] = true
      end
      if not allowed_scopes[scope] then
        return error_result("invalid_scope", "Scope exceeds limits")
      end
    end
  end
end

local expiry 

if grant_type == "access_token" then
  expiry = db:query({ "SELECT FLOOR(EXTRACT(EPOCH FROM ? - now())) AS access_time_left", token.expiry }, "object")
else
  expiry = db:query({ 
      "SELECT now() + (? || 'sec')::interval AS refresh, now() + (? || 'sec')::interval AS access",
      config.oauth2.refresh_token_lifetime,
      config.oauth2.access_token_lifetime
  }, "object")
end

if grant_type == "refresh_token" then
  local requested_detached_scopes_list = {}
  for scope in pairs(requested_detached_scopes) do
    requested_detached_scopes_list[#requested_detached_scopes_list+1] = scope
  end
  local tokens_to_reduce = Token:old_refresh_token_by_token(token, requested_detached_scopes_list)
  for dummy, t in ipairs(tokens_to_reduce) do
    local t_scopes = {}
    for t_scope in string.gmatch(t.scope, "[^ ]+") do
      t_scopes[t_scope] = true
    end
    for scope in pairs(requested_detached_scopes) do
      local scope_without_detached = string.gmatch(scope, "(.+)_detached")
      if t_scope[scope] then
        t_scope[scope] = nil
        t_scope[scope_without_detached] = true
      end
    end
    local t_scope_list = {}
    for scope in pairs(t_scopes) do
      t_scope_list[#t_scope_list+1] = scope
    end
    t.scope = table.concat(t_scope_list, " ")
    t:save()
  end
end

local r = json.object()

local refresh_token
if 
  grant_type ~= "access_token"
  and (grant_type == "authorization_code" or #(Token:fresh_refresh_token_by_token(token)) == 0)
then
  refresh_token = Token:new()
  refresh_token.token_type = "refresh"
  if grant_type == "authorization_code" then
    refresh_token.authorization_token_id = token.id
  else
    refresh_token.authorization_token_id = token.authorization_token_id
  end
  refresh_token.member_id = token.member_id
  refresh_token.system_application_id = token.system_application_id
  refresh_token.domain = token.domain
  refresh_token.session_id = token.session_id
  refresh_token.expiry = expiry.refresh
  refresh_token.scope = token.scope
  refresh_token:save()
  r.refresh_token = refresh_token.token
end


r.token_type = "bearer"
if grant_type == "access_token" then
  r.expires_in = expiry.access_time_left
else
  r.expires_in = config.oauth2.access_token_lifetime
end

for i = 0, #scopes do
  if scopes[i] then
    local scope = scopes[i]
    local access_token = Token:new()
    access_token.token_type = "access"
    if grant_type == "authorization_code" then
      access_token.authorization_token_id = token.id
    else
      access_token.authorization_token_id = token.authorization_token_id
    end
    access_token.member_id = token.member_id
    access_token.system_application_id = token.system_application_id
    access_token.domain = token.domain
    access_token.session_id = token.session_id
    if grant_type == "access_token" then
      access_token.expiry = token.expiry
    else
      access_token.expiry = expiry.access
    end
    access_token.scope = scope
    access_token:save()
    if refresh_token then
      local refresh_token_scope = TokenScope:new()
      refresh_token_scope.token_id = refresh_token.id
      refresh_token_scope.index = i
      refresh_token_scope.scope = scope
      refresh_token_scope:save()
    end
    local index = i == 0 and "" or i
    r["access_token" .. index] = access_token.token
  end
end

r.member_id = token.member_id
if token.member.role then
  r.member_is_role = true
end
if token.session then
  r.real_member_id = token.real_member_id  
end

if param.get("include_member", atom.boolean) then
  if allowed_scopes.identification or allowed_scopes.authentication then
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
    if allowed_scopes.identification then
      r.member.identification = member.identification
      if token.session and token.session.real_member then
        r.real_member.identification = token.session.real_member.identification
      end
    end
  end
end

slot.put_into("data", json.export(r))
