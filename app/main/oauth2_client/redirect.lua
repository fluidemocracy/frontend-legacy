local provider = param.get("provider")
local provider_config = config.oauth2_providers[provider]
if not provider_config then
  return
end

local params = {
  response_type = "code",
  redirect_uri = request.get_absolute_baseurl() .. "oauth2_client/callback.html?provider=" .. provider,
  client_id = provider_config.client_id,
  --scope = provider_config.scope,
  state = app.session:additional_secret_for("oauth"),
}

if provider_config.additional_auth_params then
  for key, val in pairs(provider_config.additional_auth_params) do
    params[key] = val
  end
end

local params_list = {}
for key, val in pairs(params) do
  table.insert(params_list, encode.url_part(key) .. "=" .. encode.url_part(val))
end

local url = provider_config.auth_url .. "?" .. table.concat(params_list, "&")

request.redirect{ external = url }

