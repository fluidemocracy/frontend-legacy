local profile = app.session.member.profile

for i, field in ipairs(config.member_profile_fields) do
  if not util.is_profile_field_locked(app.session.member, field.id) and not field.validate_func then
    local value = param.get(field.id)
    if value == "" then 
      value = null
    end
    profile.profile[field.id] = value
  end
end

if not util.is_profile_field_locked(profile, "statement") then
  local formatting_engine = param.get("formatting_engine") or config.enforce_formatting_engine

  local formatting_engine_valid = false
  for i, fe in pairs(config.formatting_engines) do
    if formatting_engine == fe.id then
      formatting_engine_valid = true
    end
  end
  if not formatting_engine_valid then
    error("invalid formatting engine!")
  end


  local statement = param.get("statement")

  if statement ~= profile.statement or 
     formatting_engine ~= profile.formatting_engine then
    profile.formatting_engine = formatting_engine
    profile.statement = statement
    profile:render_content(true)
  end

end

if not util.is_profile_field_locked(profile, "birthday") then
  if tostring(profile.birthday) == "invalid_date" then
    profile.birthday = nil
    slot.put_into("error", _"Date format is not valid. Please use following format: YYYY-MM-DD")
    return false
  end
end

local search_strings = {}
for i, field in ipairs(config.member_profile_fields) do
  if field.index and profile.profile[field.id] and #(profile.profile[field.id]) > 0 then
    search_strings[#search_strings+1] = profile.profile[field.id]
  end
end

if profile.statement and #(profile.statement) > 0 then
  search_strings[#search_strings+1] = profile.statement
end

profile.profile_text_data = table.concat(search_strings, " ")

profile:save()


slot.put_into("notice", _"Your page has been updated")
