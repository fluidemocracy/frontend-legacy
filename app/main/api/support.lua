local initiative_id = param.get("initiative_id")

local success = util.add_support(initiative_id)

slot.set_layout(nil, "application/json")

local r = json.array()

if success then
  r.status = "ok"
else
  r.status = "error"
end

slot.put_into("data", json.export(json.object{ result = r }))
slot.put_into("data", "\n")

