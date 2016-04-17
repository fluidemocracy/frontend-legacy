local disable_notifications = param.get("disable_notifications") == "true" and true or false

if app.session.member.disable_notifications ~= disable_notifications then
  IgnoredArea:destroy_by_member_id(app.session.member_id)
  app.session.member.disable_notifications = disable_notifications
end

if param.get("digest", atom.boolean) then
  local dow = param.get("digest_dow")
  if dow == "daily" then
    app.session.member.digest_dow = nil
  else
    app.session.member.digest_dow = tonumber(dow)
  end
  app.session.member.digest_hour = param.get("digest_hour", atom.number)
else
  app.session.member.digest_dow = nil
  app.session.member.digest_hour = nil
end

app.session.member:save()
