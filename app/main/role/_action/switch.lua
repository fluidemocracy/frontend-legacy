local id = param.get_id()

local member_id = app.session.real_member_id or app.session.member_id

if id then
  local member = Member:by_id(id)

  if member.locked then
    return
  end

  local agent = Agent:by_pk(member.id, member_id)

  if not agent then
    return
  end

  local session = Session:new()
  session.member_id = member.id
  session.real_member_id = member_id
  session:save()

  if not member.activated then
    member.activated = "now"
  end

  member.last_login = "now"
  member.last_activity = "now"
  member.active = true
  member:save()

  app.session:destroy()

  request.set_cookie{
    name = config.cookie_name or "liquid_feedback_session",
    value = session.ident
  }
elseif app.session.real_member_id then
  local session = Session:new()
  session.member_id = app.session.real_member_id
  session:save()

  app.session:destroy()

  request.set_cookie{
    name = config.cookie_name or "liquid_feedback_session",
    value = session.ident
  }
end

if config.meta_navigation_home_url then
  request.redirect{ external = config.meta_navigation_home_url }
else
  request.redirect{ module = "index", view = "index" }
end
