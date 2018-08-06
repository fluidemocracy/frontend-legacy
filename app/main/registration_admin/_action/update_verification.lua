local verification = Verification:by_id(param.get_id())

local function update_data()
  verification.verification_data = json.object()
  
  for i, field in ipairs(config.self_registration.fields) do
    local value = param.get(field.name)
    if field.name == "fiscal_code" then
      value = string.gsub(value, "[^A-Z0-9]", "")
    elseif field.name == "mobile_phone" then
      value = string.gsub(value, "[^0-9]", "")
    elseif field.name == "unit" then
      value = string.gsub(value, "[^0-9]", "")
      if value ~= verification.verification_data.unit then
        if verification.verification_data.unit then
          local old_unit_privilege = Privilege:by_pk(verification.verified_member_id, verification.verification_data.unit)
          old_unit_privilege:destroy()
        end
        local unit_privilege = Privilege:new()
        unit_privilege.member_id = verification.verified_member_id
        unit_privilege.unit_id = verification.verification_data.unit
        unit_privilege.voting_right = true
        unit_privilege.initiative_right = true
        unit_privilege.save()
      end
    elseif field.type ~= "image" then
      value = string.gsub(value, "^%s+", "")
      value = string.gsub(value, "%s+$", "")
      value = string.gsub(value, "%s+", " ")
    end
    verification.verification_data[field.name] = value
  end
end

if verification.verified_member_id then
  
  local member = Member:by_id(verification.verified_member_id)
  
  if param.get("cancel") then
    db:query({ "SELECT delete_member(?)", member.id })
    return
  end
  
  member.identification = param.get("identification")
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
  
  local member = Member:by_id(verification.requesting_member_id)
  member.identification = param.get("identification")
  member.notify_email = param.get("email")
  member:save()
  member:send_invitation()

  for i, unit_id in ipairs(config.self_registration.grant_privileges_for_unit_ids) do
    local privilege = Privilege:new()
    privilege.member_id = member.id
    privilege.unit_id = unit_id
    privilege.initiative_right = true
    privilege.voting_right = true
    privilege:save()
  end

  update_data()
  
  verification.verified_member_id = verification.requesting_member_id
  verification.verifying_member_id = app.session.member_id
  verification.verified = "now"
  
  verification:save()
  
  
else

  update_data()
  verification:save()

end
