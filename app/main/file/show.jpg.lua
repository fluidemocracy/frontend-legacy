local id = param.get_id()

local file = File:by_id(id)

local output = file.data

if param.get("preview", atom.boolean) then
  output = file.preview_data
end

slot.set_layout(nil, file.content_type)
slot.put_into("data", output)
