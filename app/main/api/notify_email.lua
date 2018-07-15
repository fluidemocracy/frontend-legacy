slot.set_layout(nil, "application/json")

local r = json.object{}

if not app.scopes.notify_email then
  return util.api_error(403, "Forbidden", "insufficient_scope", "Scope notify_email required")
end

if app.access_token.member.notify_email ~= "" then
  r.notify_email = app.access_token.member.notify_email
else
  r.notify_email = json.null
end

slot.put_into("data", json.export(json.object{ result = r }))
slot.put_into("data", "\n")
