slot.set_layout(nil, "application/json")

local r = config.platform_config

slot.put_into("data", json.export(json.object{ result = r }))
