local suggestion_id = param.get("suggestion_id", atom.integer)
local degree = param.get("degree", atom.number)
local fulfilled = param.get("fulfilled", atom.boolean)

print(degree, fulfilled)

slot.set_layout()

if Opinion:update(suggestion_id, app.session.member_id, degree, fulfilled) then
  slot.put_into("data", "ok")
else
  request.set_status("500 Internal Server Error")
end

