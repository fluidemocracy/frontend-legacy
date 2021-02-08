slot.set_layout(nil, "application/json")

if not (
  app.scopes.read_authors
  or app.scopes.read_identities 
  or app.scopes.read_profiles
) then
  return util.api_error(403, "Forbidden", "insufficient_scope", "Scope read_authors or read_identities or read_profiles required")
end

local r = json.object{
  result = json.array()
}

local selector = MemberImage:new_selector()
  :add_where("image_type = 'avatar'")
  :add_where("scaled")
  :optional_object_mode()

local member_id = param.get("member_id")
if member_id then
  selector:add_where{ "member_id = ?", member_id }
else
  return util.api_error(404, "Missing parameter", "no_member_id", "No member_id provided")
end

local member_image = selector:exec()

local data
local content_type

if member_image then
  data = member_image.data
  content_type = member_image.content_type
else
  local filename = WEBMCP_BASE_PATH .. "static/avatar.jpg"
  local f = assert(io.open(filename), "Cannot open default image file")
  data = f:read("*a")
  content_type = "image/jpeg"
  f:close()
end

slot.set_layout(nil, "image/jpeg")
slot.put_into("data", data)

