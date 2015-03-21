local image_type = param.get("image_type")
local record = MemberImage:by_pk(param.get_id(), image_type, true)

if record == nil then
  local default_file = ({ avatar = "avatar.jpg", photo = nil })[image_type] or 'icons/16/lightning.png'
  request.redirect{ static = default_file }
  return
end

assert(record.content_type, "No content-type set for image.")

slot.set_layout(nil, record.content_type)

if record then
  request.add_header("Cache-Control", "max-age=300"); -- let the client cache the image for 5 minutes
  slot.put_into("data", record.data)
end
