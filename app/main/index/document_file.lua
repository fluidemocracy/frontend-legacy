if not config.document_dir then
  return execute.view { module = "index", view = "404" }
end

local filename = param.get("filename")

local file = io.open(encode.file_path(config.document_dir, filename))

if not file then
  return execute.view { module = "index", view = "404" }
end

if param.get("inline") then
  request.add_header("Content-disposition", "inline; filename=" .. filename)
else
  request.add_header("Content-disposition", "attachment; filename=" .. filename)
end

local data = file:read("*a")

slot.set_layout(nil, content_type)
slot.put_into("data", data)

