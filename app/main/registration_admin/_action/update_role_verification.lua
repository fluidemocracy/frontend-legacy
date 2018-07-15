local verification = RoleVerification:by_id(param.get_id())

local function update_data()
  verification.verification_data = json.object()
  
  for i, field in ipairs(config.role_registration.fields) do
    local value = param.get(field.name)
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    value = string.gsub(value, "%s+", " ")
    verification.verification_data[field.name] = value
  end
end

if verification.verified then
  
  local member = Member:by_id(verification.verified_member_id)
  
  if param.get("cancel") then
    db:query({ "SELECT delete_member(?)", member.id })
    return
  end
  
  member.identification = param.get("identification")
  member.name = param.get("screen_name")
  member.notify_email = param.get("email")
  member:save()
  
  update_data()
  
  verification:save()

  if param.get("invite") then
    member:send_invitation()
  end

elseif param.get("drop") then
  
  verification.denied = "now"
  verification:save()
  return
  
elseif param.get("accredit") then
  
  local member = Member:new()
  member.role = true
  member.identification = param.get("identification")
  member.name = param.get("screen_name")
  member.notify_email = param.get("email")
  member:save()

  for i, unit_id in ipairs(config.role_registration.grant_privileges_for_unit_ids) do
    local privilege = Privilege:new()
    privilege.member_id = member.id
    privilege.unit_id = unit_id
    privilege.initiative_right = false -- TODO
    privilege.voting_right = true
    privilege:save()
  end
  
  local agent = Agent:new()
  agent.controlled_id = member.id
  agent.controller_id = verification.requesting_member_id
  agent:save()

  update_data()
  
  verification.verified_member_id = member.id
  verification.verifying_member_id = app.session.member_id
  verification.verified = "now"
  
  verification:save()
  
end
