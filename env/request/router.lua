local api_endpoints = {
  instance = true,
  navigation = true,
  style = true,
  application = true,
  info = true,
  member = true,
  notify_email = true,
  profile_info = true,
  profile = true,
  settings_info = true,
  settings = true,
  event = true,
  support = true,
  embed_initiative = true
}

function request.router()
  
  local api_prefix = "api/1/"
  
  local path = request.get_path()
  
  if path == api_prefix .. "register" then
    return { module = "oauth2", view = "register" }
  elseif path == api_prefix .. "authorization" then
    return { module = "oauth2", view = "authorization" }
  elseif path == api_prefix .. "token" then
    return { module = "oauth2", view = "token" }
  elseif path == api_prefix .. "validate" then
    return { module = "oauth2", view = "validate" }
  elseif path == api_prefix .. "session" then
    return { module = "oauth2", view = "session" }
  else
    local endpoint = string.match(path, "^" .. api_prefix .. "(.*)$")
    if api_endpoints[endpoint] then
      return { module = "api", view = endpoint }
    end
  end
  
  return request.default_router(path)
  
end
