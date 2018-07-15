if not app.session.member or app.session.member.role then
  return
end

local errors = 0

if config.use_terms_checkboxes_role then
  for i, checkbox in ipairs(config.use_terms_checkboxes_role) do
    local accepted = param.get("use_terms_checkbox_" .. checkbox.name, atom.boolean)
    if not accepted then
      slot.put_into("error", checkbox.not_accepted_error)
      errors = errors + 1
    end
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

local verification = RoleVerification:new()
verification.requesting_member_id = app.session.member_id
verification.requested = "now"
verification.request_origin = json.object{
  ip = request.get_header("X-Forwarded-For"),
  hostname = request.get_header("X-Forwarded-Host")
}
verification.request_data = json.object()

for i, field in ipairs(config.role_registration.fields) do
  local value = param.get("verification_data_" .. field.name)
  if not value or #value < 1 then
    slot.put_into("self_registration__invalid_" .. field.name, "to_short")
    slot.select("error", function()
      ui.container{ content = _("Please enter: #{field_name}", { field_name = field.label }) }
    end)
    errors = errors + 1
  end
  value = string.gsub(value, "^%s+", "")
  value = string.gsub(value, "%s+$", "")
  value = string.gsub(value, "%s+", " ")
  verification.request_data[field.name] = value
end

verification:save()

request.redirect{ external = encode.url { module = "member", view = "show", id = app.session.member_id } } 
