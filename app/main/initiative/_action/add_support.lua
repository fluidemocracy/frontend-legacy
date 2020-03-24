local initiative_id = param.get_id()
local draft_id = param.get("draft_id", atom.integer)

return util.add_support(initiative_id, draft_id)
