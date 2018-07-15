local public_access_scopes = {
  anonymous = "read_contents",
  authors_pseudonymous = "read_contents read_authors",
  all_pseudonymous = "read_contents read_authors read_ratings",
  everything = "read_contents read_authors read_ratings read_identities read_profiles"
}

local access_token, access_token_err = util.get_access_token()

if access_token_err then
  if access_token_err == "header_and_param" then
    return util.api_error(400, "Unauthorized", "invalid_request", "Access token passed both via header and param")
  end
  return util.api_error(500, "Internal server error", "internal_error", "Internal server error")
end

local scope

if access_token then
  local token = Token:by_token_type_and_token("access", access_token)
  if token then
    app.access_token = token
    scope = token.scope
  else
    return util.api_error(401, "Unauthorized", "invalid_token", "The access token is invalid or expired")
  end
end

if not scope then
  scope = public_access_scopes[config.public_access]
end

if not scope then
  return util.api_error(403, "Forbidden", "insufficient_scope", "Public access is not allowed at this instance.")
end

app.scopes = {}

for scope in string.gmatch(scope, "[^ ]+") do
  local match = string.match(scope, "(.+)_detached")
  app.scopes[match or scope] = true
end

if not next(app.scopes) then
  return util.api_error(403, "Forbidden", "insufficient_scope", "No valid scope found")
end

execute.inner()
