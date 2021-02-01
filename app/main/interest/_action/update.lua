local issue_id = param.get("issue_id", atom.integer)
local interested = param.get("interested", atom.boolean)

return Interest:update(issue_id, app.session.member, interested)

