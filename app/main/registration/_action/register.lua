local function check_italian_mobile_phone_number(value)

  if not value then
    return false
  end

  value = string.gsub(value, "[^0-9]*", "")

  if #(value) < 9 or #(value) > 10 then
    return false
  end

  local mobile_phone_prefixes = {
    { min = 320,  max = 329, comment = "Wind Tre" },
    { min = 330,  max = 339, comment = "Telecom Italia (TIM)" },
    { min = 340,  max = 349, comment = "Vodafone Omnitel" },
    { min = 350,  max = 359, comment = "" },
    { min = 360,  max = 369, comment = "Telecom Italia (TIM)" },
    { min = 370,  max = 379, comment = "" },
    { min = 380,  max = 389, comment = "Wind Tre" },
    { min = 390,  max = 393, comment = "Wind Tre" },
    { min = 394,  max = 399, comment = "Wind Tre" }
  }

  local value_prefix = tonumber(string.match(value, "^(...)"))

  local valid_prefix = false

  for i, prefix in ipairs(mobile_phone_prefixes) do
    trace.debug(value_prefix, prefix.min)
    if value_prefix >= prefix.min and value_prefix <= prefix.max then
      valid_prefix = true
    end
  end

  if valid_prefix then
    return true
  else
    return false
  end
end

local function check_uk_mobile_phone_number(value)

  if not value then
    return false
  end

  value = string.gsub(value, "[^0-9]*", "")

  if #(value) < 11 or #(value) > 11 then
    return false
  end

  local mobile_phone_prefixes = {
    { min = 071,  max = 079, comment = "UK phone" },
  }

  local value_prefix = tonumber(string.match(value, "^(...)"))

  local valid_prefix = false

  for i, prefix in ipairs(mobile_phone_prefixes) do
    trace.debug(value_prefix, prefix.min)
    if value_prefix >= prefix.min and value_prefix <= prefix.max then
      valid_prefix = true
    end
  end

  if valid_prefix then
    return true
  else
    return false
  end
end

local errors = 0

local manual_verification

if config.self_registration.allow_bypass_checks and param.get("manual_verification") then
  manual_verification = true
end

for i, checkbox in ipairs(config.use_terms_checkboxes) do
  local accepted = param.get("use_terms_checkbox_" .. checkbox.name, atom.boolean)
  if not accepted then
    slot.put_into("error", checkbox.not_accepted_error)
    errors = errors + 1
  end
end

local email = param.get("email")

local members = Member:new_selector()
  :add_where{ "notify_email = ? OR notify_email_unconfirmed = ?", email }
  :exec()
  
if #members > 0 then
  slot.select("error", function()
    slot.put_into("registration_register_email_invalid", "already_used")
    ui.tag{ content = _"This email address already been used. Please check your inbox for an invitation or contact us." }
  end)
  errors = errors + 1
end

local verification = Verification:new()
verification.requested = "now"
verification.request_origin = json.object{
  ip = request.get_header("X-Forwarded-For"),
  hostname = request.get_header("X-Forwarded-Host")
}
verification.request_data = json.object()

for i, field in ipairs(config.self_registration.fields) do
  if not field.internal and field.type ~= "comment" then
    if field.name == "date_of_birth" then
      local day = tonumber(param.get("verification_data_" .. field.name .. "_day"))
      local month = tonumber(param.get("verification_data_" .. field.name .. "_month"))
      local year = tonumber(param.get("verification_data_" .. field.name .. "_year"))
      local date = atom.date:new{ year = year, month = month, day = day }
      if date.invalid then
        slot.select("error", function()
          ui.container{ content = _"Please check date of birth" }
          slot.put_into("self_registration__invalid_" .. field.name, "invalid")
        end)
        errors = errors + 1
      end
      local today = atom.date:get_current()
      local min_age = config.self_registration.min_age or 16
      local date_nyears_ago = atom.date:new{ year = today.year - min_age, month = today.month, day = today.day }
      if date_nyears_ago.invalid and today.month == 2 and today.day == 29 then
        date_nyears_ago = atom.date:new{ year = today.year - min_age, month = 2, day = 28 }
      end
      if date > date_nyears_ago then
        request.redirect{ external = encode.url { module = "registration", view = "register_rejected_age" } }      
        return
      end
      verification.request_data[field.name] = string.format("%04i-%02i-%02i", year, month, day)
    
    elseif field.type == "multiselect" then
      local values = {}
      for i_options, option in ipairs(field.options) do
        if not option.id then
          option.id = option.name
        end
        local value = param.get("verification_data_" .. field.name .. "__" .. option.id)
        if value == "1" then
          if option.other then
            table.insert(values, param.get("verification_data_" .. field.name .. "_other"))
          else
            table.insert(values, option.id)
          end
        end
      end
      if not field.optional and #values < 1 then
        slot.put_into("self_registration__invalid_" .. field.name, "to_short")
        slot.select("error", function()
          ui.container{ content = _("Please enter: #{field_name}", { field_name = field.label or field.title }) }
        end)
        errors = errors + 1
      end
      verification.request_data[field.name] = table.concat(values, ", ")
    else
      local value = param.get("verification_data_" .. field.name)
      if field.type == "dropdown" then
      local other_option_id
        for i_options, option in ipairs(field.options) do
          if not option.id then
            option.id = option.name
          end
          if option.other then
            other_option_id = option.id
          end
        end
        if other_option_id and other_option_id == value then
          value = param.get("verification_data_" .. field.name .. "_other")
        end
      end
      
      local optional = false
      if field.optional then
        optional = true
      end
      if field.optional_checkbox and param.get("verification_data_" .. field.name .. "_optout", atom.boolean) then
        optional = true
      end
      if not optional and (not value or (#value < 1 and (not manual_verification or field.name ~= "mobile_phone"))) then
        slot.put_into("self_registration__invalid_" .. field.name, "to_short")
        slot.select("error", function()
          ui.container{ content = _("Please enter: #{field_name}", { field_name = field.label or field.title }) }
        end)
        errors = errors + 1
      end
      if field.name == "fiscal_code" then
        value = string.upper(value)
        value = string.gsub(value, "[^A-Z0-9]", "")
      elseif field.name == "mobile_phone" then
        value = string.gsub(value, "[^0-9]", "")
      elseif field.type == "image" then
        if field.save_func then
          value = field.save_func(value)
        end
      else
        value = string.gsub(value, "^%s+", "")
        value = string.gsub(value, "%s+$", "")
        value = string.gsub(value, "%s+", " ")
      end
      verification.request_data[field.name] = value
    end
  end

  local mobile_phone = verification.request_data.mobile_phone

  if not manual_verification then
    if config.self_registration.check_for_italien_mobile_phone then
      if not check_italian_mobile_phone_number(mobile_phone) then
        slot.select("error", function()
          ui.container{ content = _"Please check the mobile phone number (invalid format)" }
        end)
        errors = errors + 1
      end
    end

    if config.self_registration.check_for_uk_mobile_phone then
      if not check_uk_mobile_phone_number(mobile_phone) then
        slot.select("error", function()
          ui.container{ content = _"Please check the mobile phone number (invalid format)" }
        end)
        errors = errors + 1
      end
    end
  end
end

if config.self_registration.check_for_italian_fiscal_code then
  local check_fiscal_code = execute.chunk{ module = "registration", chunk = "_check_fiscal_code" }

  local fiscal_code_valid, fiscal_code_error = check_fiscal_code(
    verification.request_data.fiscal_code,
    {
      first_name = verification.request_data.first_name,
      last_name = verification.request_data.name,
      year = tonumber(string.match(verification.request_data.date_of_birth, "^(....)-..-..$")),
      month = tonumber(string.match(verification.request_data.date_of_birth, "^....-(..)-..$")),
      day = tonumber(string.match(verification.request_data.date_of_birth, "^....-..-(..)$")),
    }
  )

  if fiscal_code_valid then
    verification.comment = (verification.comment or "").. " /// Fiscal code matched"
  else
    slot.select("error", function()
      ui.container{ content = _"Please check the fiscal code (invalid format or does not match name, first name and/or date of birth)" }
    end)
    errors = errors + 1
    --table.insert(manual_check_reasons, "fiscal code does not match (" .. fiscal_code_error .. ")")
  end
end

if errors > 0 then
  return false
end

local member = Member:new()
member.notify_email = email
member:save()

for i, checkbox in ipairs(config.use_terms_checkboxes) do
  local accepted = param.get("use_terms_checkbox_" .. checkbox.name, atom.boolean)
  local member_useterms = MemberUseterms:new()
  member_useterms.member_id = member.id
  member_useterms.contract_identifier = checkbox.name
  member_useterms:save()
end

verification.requesting_member_id = member.id

local manual_check_reasons = {}

if manual_verification then
  table.insert(manual_check_reasons, "User requested manual verification (during step 1)")
end

if config.self_registration.sms_id then
  local existing_verifications = Verification:new_selector()
    :add_where{ "request_data->>'mobile_phone' = ?", mobile_phone }
    :add_where("comment ilike '%SMS code%'")
    :exec()

  if #existing_verifications > 0 then
    table.insert(manual_check_reasons, "mobile phone number already used before")
  end
end

if config.self_registration.force_manual_check then
  table.insert(manual_check_reasons, "Manual check enforced by configuration")
end

if #manual_check_reasons > 0 then
  local reasons = table.concat(manual_check_reasons, ", ")
  verification.comment = (verification.comment or "").. " /// Manual verification needed: " .. reasons
  verification:save()
  request.redirect{ external = encode.url { module = "registration", view = "register_manual_check_needed" } } 

elseif config.self_registration.sms_id then
  local pin = multirand.string(6, "0123456789")
  verification.request_data.sms_code = pin
  verification.request_data.sms_code_tries = 3
  local sms_text = config.self_registration.sms_text
  local sms_text = string.gsub(sms_text, "{PIN}", pin)
  local phone_number
  if config.self_registration.sms_strip_leading_zero then
    phone_number = string.match(verification.request_data.mobile_phone, "0(.+)")
  else
    phone_number = verification.request_data.mobile_phone
  end
  phone_number = config.self_registration.sms_prefix .. phone_number
  local params = {
    id = config.self_registration.sms_id,
    pass = config.self_registration.sms_pass,
    gateway = config.self_registration.sms_gateway,
    absender = config.self_registration.sms_from,
    text = sms_text,
    nummer = phone_number,
    test = config.self_registration.test and "1" or nil
  }
  local params_list = {}
  for k, v in pairs(params) do
    table.insert(params_list, encode.url_part(k) .. "=" .. encode.url_part(v))
  end
  
  local params_string = table.concat(params_list, "&")
  local url = "http://gateway.any-sms.biz/send_sms.php?" .. params_string
  local output, err, status = extos.pfilter(nil, "curl", url)
  verification.request_data.sms_code_sent_status = output
  if not string.match(output, "^err:0") then
    verification.comment = (verification.comment or "").. " /// Manual verification needed: sending SMS failed (" .. output .. ")"
    verification:save()
    request.redirect{ external = encode.url { module = "registration", view = "register_manual_check_needed" } } 
    return
  end
  verification.comment = (verification.comment or "") .. " /// SMS code " .. pin .. " sent"
  verification:save()
  request.redirect{ external = encode.url { module = "registration", view = "register_enter_pin", id = verification.id } }
  
else
  local success = execute.action{
    module = "registration", action = "_verify", params = {
      verification = verification
    }
  }
  if success == "ok" then
    if verification.request_data.unit then
      local unit_privilege = Privilege:new()
      unit_privilege.member_id = verification.requesting_member_id
      unit_privilege.unit_id = tonumber(verification.request_data.unit)
      unit_privilege.voting_right = true
      unit_privilege.initiative_right = true
      unit_privilege:save()
    end
    request.redirect{ external = encode.url { module = "registration", view = "register_completed" } } 
  end
  
end



