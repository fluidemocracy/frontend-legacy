if not request.is_post() then
  return execute.view { module = "index", view = "405" }
end

slot.set_layout(nil, "application/json")

local r = json.object{
  member_id = json.null
}

if app.session and app.session.member_id then
  local origin = request.get_header("Origin")
  if origin then
    local system_applications = SystemApplication:by_origin(origin)
    if #system_applications > 0 then
      r.member_id = app.session.member_id
      r.real_member_id = app.session.real_member_id
      if app.session.member.role then
        r.member_is_role = true
      end
    else
      local member_application = MemberApplication:by_member_id_and_origin(app.session.member_id, origin)
      if member_application then
        r.member_id = app.session.member_id
        r.real_member_id = app.session.real_member_id
      end
    end
  end
end

slot.put_into("data", json.export(r))

