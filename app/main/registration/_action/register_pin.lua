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

local success = execute.action{
  module = "registration", action = "_verify", params = {
    verification = verification
  }
}
if success == "ok" then
  request.redirect{ external = encode.url { module = "registration", view = "register_completed" } } 
end

