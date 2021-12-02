local verification = Verification:by_id(param.get_id())

local function update_data()
  local old_verification_data = verification.verification_data or {}
  verification.verification_data = json.object()
  
  for i, field in ipairs(config.self_registration.fields) do
    local value = param.get(field.name)
    if field.name == "fiscal_code" then
      value = string.gsub(value, "[^A-Z0-9]", "")
    elseif field.name == "mobile_phone" then
      value = string.gsub(value, "[^0-9]", "")
    elseif field.name == "unit" then
      value = string.gsub(value, "[^0-9]", "")
      if old_verification_data.unit and old_verification_data.unit ~= "" and old_verification_data.unit ~= value then
        local old_unit_privilege = Privilege:by_pk(old_verification_data.unit, verification.requesting_member_id)
        if old_unit_privilege then
          old_unit_privilege:destroy()
        end
      end
      if value ~= old_verification_data.unit and value ~= "" then
        local unit_privilege = Privilege:new()
        unit_privilege.member_id = verification.requesting_member_id
        unit_privilege.unit_id = tonumber(value)
        unit_privilege.voting_right = true
        unit_privilege.initiative_right = true
        unit_privilege:save()
      end
    elseif field.name == "sequential_number" then
      value = old_verification_data.sequential_number 
      if not value then
        local last_sequential_number = 0
        db:query('LOCK TABLE "verification" IN SHARE ROW EXCLUSIVE MODE')
        local record = Verification:new_selector()
          :reset_fields()
          :add_field("max((verification_data->>'sequential_number')::int8)", "max_sequential_number")
          :optional_object_mode()
          :exec()
        if record and record.max_sequential_number then
          last_sequential_number = record.max_sequential_number
        end
        value = last_sequential_number + 1
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
  
  local identification = param.get("identification")
  if identification and #identification == 0 then
    identification = nil
  end
  member.identification = identification

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

  if config.self_registration.manual_invitation then
    local function secret_token()
      local parts = {}
      for i = 1, 5 do
        parts[#parts+1] = multirand.string(5, "23456789bcdfghjkmnpqrstvwxyz")
      end
      return (table.concat(parts, "-"))
    end
    member.invite_code = secret_token()
    member:save()
  else
    member:send_invitation()
  end

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
