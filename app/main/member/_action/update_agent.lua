if not config.role_registration then
  return
end
if not app.session.member.role then
  return
end

local controller_id = param.get("controller_id")

local member = Member:by_id(controller_id)

if member.role then
  return
end

local agent = Agent:by_pk(app.session.member_id, controller_id)

if param.get("delete") then
  agent:destroy()
  return
end

if not agent then
  agent = Agent:new()
  agent.controlled_id = app.session.member_id
  agent.controller_id = controller_id
  agent:save()
end

