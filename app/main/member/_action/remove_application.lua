local id = param.get_id()

local application = MemberApplication:by_id(id)

if application.member_id ~= app.session.member_id then
  return
end

application:destroy()

