local file_upload_session = param.get("file_upload_session")
file_upload_session = string.gsub(file_upload_session, "[^A-Za-z0-9]", "")

local file_id = param.get("file_id")
file_id = string.gsub(file_id, "[^A-Za-z0-9]", "")

local filename = encode.file_path(WEBMCP_BASE_PATH, 'tmp', "file_upload-" .. file_upload_session .. "-" .. file_id .. ".jpg")

if param.get("preview", atom.boolean) then
  filename = encode.file_path(WEBMCP_BASE_PATH, 'tmp', "file_upload-" .. file_upload_session .. "-" .. file_id .. ".preview.jpg")
end

local data

local fh = io.open(filename, "r")
if fh then
  data = fh:read("*a")
end


slot.set_layout(nil, content_type)
slot.put_into("data", data)
