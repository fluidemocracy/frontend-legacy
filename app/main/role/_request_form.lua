for i, field in ipairs(config.role_registration.fields) do
  local class = ""
  local field_error = slot.get_content("role_registration__invalid_" .. field.name)
  if field_error == "" then
    field_error = nil
  end
  if field_error then
    class = " is-invalid"
  end
  ui.field.text{
    container_attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label" .. class },
    attr = { id = "lf-register__data_" .. field.name, class = "mdl-textfield__input" },
    label_attr = { class = "mdl-textfield__label", ["for"] = "lf-register__data" .. field.name },
    label = field.label,
    name = "verification_data_" .. field.name,
    value = request.get_param{ name = "verification_data_" .. field.name }
  }
  slot.put("<br />")
end
