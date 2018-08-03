local field = param.get("field", atom.number)
local id = param.get_id(atom.string)

if not string.match(id, "[0-9a-z]") then
  return
end

local field_load_func = config.self_registration.fields[field].load_func

slot.set_layout(nil, "image/jpeg")

slot.put_into("data", field_load_func(id))
