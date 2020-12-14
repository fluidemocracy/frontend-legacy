if not app.scopes.login then
  request.redirect{ external = request.get_absolute_baseurl() .. "index/login.html" }
  return
end

if not app.access_token.used then
  app.session:set_cookie()
  local result = util.login(app.access_token.member)

  if not result then
    request.redirect{ external = request.get_absolute_baseurl() .. "index/login.html" }
    return
  end
  app.access_token.used = true
  app.access_token:save()
end

local redir_url = param.get("redir_url")

if not redir_url then
  request.redirect{ external = request.get_absolute_baseurl() }
  return
end

request.redirect{ external = redir_url }

