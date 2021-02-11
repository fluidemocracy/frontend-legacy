local issue_id = param.get("issue_id", atom.integer)
local interested = param.get("interested", atom.boolean)

slot.set_layout()

if Interest:update(issue_id, app.session.member, interested) then
  slot.put_into("data", "ok")
else
  request.set_status("500 Internal Server Error")
end

