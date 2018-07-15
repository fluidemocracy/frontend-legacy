function util.api_error(status_code, status_text, error_code, error_description)
  slot.set_layout(nil, "application/json")
  request.set_status(status_code, status_text)
  if status_code == 401 then
    request.add_header("WWW-Authenticate", "Bearer error=\"" .. error_code .. "\", error_description=\"" .. error_description .. "\"")
  end
  slot.put_into("data", json.export(json.object{
    error = error_code,
    error_description = error_description
  }))
  return false
end
