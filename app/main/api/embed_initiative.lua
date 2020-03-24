if app.scopes.identification then
  app.session.member_id = app.access_token.member_id
  app.session:save()
  request.redirect{ external = request.get_absolute_baseurl() .. "initiative/show/" .. param.get("id") .. ".html" }
else
  slot.put("missing access token or scope")
end

