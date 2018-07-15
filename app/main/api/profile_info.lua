slot.set_layout(nil, "application/json")

local r = json.object()

r.result = json.array()
for i, field in ipairs(config.member_profile_fields) do
  table.insert(r.result, json.object{
    id = field.id,
    name = field.name,
    type = field.type
  })
end

slot.put_into("data", json.export(r))
slot.put_into("data", "\n")

