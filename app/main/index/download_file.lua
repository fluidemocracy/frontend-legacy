if not config.download_dir then
  return execute.view { module = "index", view = "404" }
end

local filename = param.get("filename")

local file = assert(io.open(encode.file_path(config.download_dir, filename)), "file not found")

print('Content-type: application/octet-stream')
print('Content-disposition: attachment; filename=' .. filename)
print('')

io.stdout:write(file:read("*a"))

exit()
