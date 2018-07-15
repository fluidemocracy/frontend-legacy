if not request.is_post() then
  return execute.view { module = "index", view = "405" }
end

slot.set_layout(nil, "application/json;charset=UTF-8")

local r = json.object()

local function error_result(error_code, error_description)
  -- TODO special HTTP status codes for some errors?
  request.set_status("400 Bad Request")
  slot.put_into("data", json.export{ 
    error = error_code,
    error_description = error_description
  })
end

local client_id = param.get("client_id")
local flow = param.get("flow")
local scope = param.get("scope")

if flow ~= "code" and flow ~= "token" then
  return error_result("invalid_request", "invalid flow")
end

local domain

if client_id then
  domain = string.match(client_id, "^dynamic:([a-z0-9.-]+)$")
  if not domain then
    return error_result("invalid_client", "invalid client_id (use lower case host name prefixed with 'dynamic:')")
  end
end

local cert_ca = request.get_header("X-LiquidFeedback-CA")
local cert_distinguished_name = request.get_header("X-SSL-DN")
local cert_common_name

if cert_distinguished_name then
  cert_common_name = string.match(cert_distinguished_name, "%f[^/\0]CN=([A-Za-z0-9_.-]+)%f[/\0]")
  if not cert_common_name then
    return error_result("invalid_client", "CN in X.509 certificate invalid")
  end
else
  return error_result("invalid_client", "X.509 client authorization missing")
end

if cert_ca ~= "public" then
  return error_result("invalid_client", "X.509 certificate not signed by publicly trusted certificate authority or wrong endpoint used")
end

if domain then
  if domain ~= cert_common_name then
    return error_result("invalid_grant", "CN in X.509 certificate incorrect")
  end
else
  domain = cert_common_name
end

local redirect_uri = "https://" .. domain .. "/" .. config.oauth2.endpoint_magic

local expiry = db:query({ "SELECT now() + (? || 'sec')::interval AS expiry", config.oauth2.dynamic_registration_lifetime }, "object").expiry
  
for s in string.gmatch(scope, "[^ ]+") do
  local dynamic_application_scope = DynamicApplicationScope:new()
  dynamic_application_scope.redirect_uri = redirect_uri
  dynamic_application_scope.flow = flow
  dynamic_application_scope.scope = s
  dynamic_application_scope.expiry = expiry
  dynamic_application_scope:upsert_mode()
  dynamic_application_scope:save()
end

r.client_id = "dynamic:" .. domain
r.expires_in = config.oauth2.dynamic_registration_lifetime

slot.put_into("data", json.export(r))
