local id = param.get_id()
local verification = Verification:by_id(id)

if not verification then
  return false
end

local pin = param.get("pin")

if param.get("manual_verification") then
  verification.comment = (verification.comment or "") .. " /// User requested manual verification (during step 2)"
  verification:save()
  request.redirect{ external = encode.url { module = "registration", view = "register_manual_check_needed" } } 
  return false
elseif verification.request_data.sms_code ~= pin then
  verification.request_data.sms_code_tries = verification.request_data.sms_code_tries - 1
  verification.comment = (verification.comment or "") .. " /// User entered wrong PIN " .. pin
  if verification.request_data.sms_code_tries > 0 then
    verification:save()
    request.redirect{ external = encode.url { module = "registration", view = "register_enter_pin", id = verification.id, params = { invalid_pin = true } } } 
    return false
  else
    verification.comment = (verification.comment or "") .. " /// Manual verification needed: user entered invalid PIN three times"
    verification:save()
    request.redirect{ external = encode.url { module = "registration", view = "register_manual_check_needed" } } 
    return false
  end
end

verification.comment = (verification.comment or "").. " /// User entered correct PIN code"

verification.verified = "now"
verification.verification_data = verification.request_data

local identification = config.self_registration.identification_func(verification.request_data)

local members_with_same_identification = Member:new_selector()
  :add_where{ "identification = ?", identification }
  :exec()

if #members_with_same_identification > 0 then
  verification.comment = (verification.comment or "").. " /// Manual verification needed: user with same name already exists"
  verification:save()
  request.redirect{ external = encode.url { module = "registration", view = "register_manual_check_needed" } }
  return false
end

local member = Member:by_id(verification.requesting_member_id)

member.identification = identification
member.notify_email = verification.request_data.email

member:send_invitation()

for i, unit_id in ipairs(config.self_registration.grant_privileges_for_unit_ids) do
  local privilege = Privilege:new()
  privilege.member_id = member.id
  privilege.unit_id = unit_id
  privilege.initiative_right = true
  privilege.voting_right = true
  privilege:save()
end

verification.verified_member_id = member.id

verification.comment = (verification.comment or "").. " /// Account created"

verification:save()


request.redirect{ external = encode.url { module = "registration", view = "register_completed" } } 
