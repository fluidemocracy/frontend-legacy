local member = param.get("member", "table")
local member_id = member and member.id or param.get("member_id", atom.integer)

local image_type = param.get("image_type")
local class = param.get("class")
local popup_text = param.get("popup_text")

local force_update = param.get("force_update", atom.boolean)

if class then
  class = class .. " "
else
  class = ""
end

if image_type == "avatar" then
  class = class .. "mdl-chip__contact "
end

ui.image{
  attr = { title = popup_text, class = class .. " member_image member_image_" .. image_type },
  module = "member_image",
  view = "show",
  extension = "jpg",
  id = member_id,
  params = {
    image_type = image_type,
    dynamic = force_update and os.time() or nil
  }
}

