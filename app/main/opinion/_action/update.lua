local suggestion_id = param.get("suggestion_id", atom.integer)
local degree = param.get("degree", atom.number)
local fulfilled = param.get("fulfilled", atom.boolean)

return Opinion:update(suggestion_id, app.session.member_id, degree, fulfilled)

