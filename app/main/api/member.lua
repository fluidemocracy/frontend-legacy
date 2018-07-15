slot.set_layout(nil, "application/json")

local r = json.object{
  result = json.array()
}

local selector = Member:new_selector()
  :add_where("activated NOTNULL")
  :add_order_by("id")

if param.get("id") then
  selector:add_where{ "id = ?", param.get("id") }
end

local members = selector:exec()
local r.result = execute.chunk{ module = "api", chunk = "_member", params = { members = members } } 


slot.put_into("data", json.export(r))
slot.put_into("data", "\n")
