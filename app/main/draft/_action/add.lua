local draft_text = param.get("content")

if not draft_text then
  return false
end

local draft_text = util.wysihtml_preproc(draft_text)

local valid_html, error_message = util.html_is_safe(draft_text)
if not valid_html then
  slot.put_into("error", _("Draft contains invalid formatting or character sequence: #{error_message}", { error_message = error_message }) )
  return false
end

if config.initiative_abstract then
  local abstract = param.get("abstract")
  if not abstract then
    return false
  end
  abstract = encode.html(abstract)
  draft_text = abstract .. "<!--END_OF_ABSTRACT-->" .. draft_text
end

if config.attachments then
  local file_upload_session = param.get("file_upload_session")
  file_upload_session = string.gsub(file_upload_session, "[^A-Za-z0-9]", "")
  local file_uploads = json.array()
  local filename = encode.file_path(WEBMCP_BASE_PATH, 'tmp', "file_upload-" .. file_upload_session .. ".json")
  local fh = io.open(filename, "r")
  if fh then
    file_uploads = json.import(fh:read("*a"))
  end
  for i, file_upload in ipairs(file_uploads) do
    if param.get("file_upload_delete_" .. file_upload.id, atom.boolean) then
      for j = i, #file_uploads - 1 do
        file_uploads[j] = file_uploads[j+1]
      end
      file_uploads[#file_uploads] = nil
    end
  end
  local convert_func = config.attachments.convert_func
  local last_id = param.get("file_upload_last_id", atom.number)
  if last_id and last_id > 0 then
    if last_id > 1024 then
      last_id = 1024
    end
    for i = 1, last_id do
      local file = param.get("file_" .. i)
      if file and #file > 0 then
        local id = multirand.string(
          32,
          '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
        )
        local data, err, status = convert_func(file)
        if status ~= 0 or data == nil then
          slot.put_into("error", _"Error while converting image. Please note, that only JPG files are supported!")
          return false
        end
        local filename = encode.file_path(WEBMCP_BASE_PATH, 'tmp', "file_upload-" .. file_upload_session .. "-" .. id .. ".jpg")
        local fh = assert(io.open(filename, "w"))
        fh:write(file)
        fh:write("\n")
        fh:close()
        local filename = encode.file_path(WEBMCP_BASE_PATH, 'tmp', "file_upload-" .. file_upload_session .. "-" .. id .. ".preview.jpg")
        local fh = assert(io.open(filename, "w"))
        fh:write(data)
        fh:write("\n")
        fh:close()
        table.insert(file_uploads, json.object{
          id = id,
          filename = filename,
          title = param.get("title_" .. i),
          description = param.get("description_" .. i)
        })
      end
    end
  end
  local filename = encode.file_path(WEBMCP_BASE_PATH, 'tmp', "file_upload-" .. file_upload_session .. ".json")
  local fh = assert(io.open(filename, "w"))
  fh:write(json.export(file_uploads))
  fh:write("\n")
  fh:close()
end

local draft_id = Draft:update_content(
  app.session.member.id, 
  param.get("initiative_id", atom.integer),
  param.get("formatting_engine"),
  draft_text,
  nil,
  param.get("preview") or param.get("edit")
)

if draft_id and config.attachments then
  local file_upload_session = param.get("file_upload_session")
  file_upload_session = string.gsub(file_upload_session, "[^A-Za-z0-9]", "")

  local draft_attachments = DraftAttachment:new_selector()
    :add_where{ "draft_attachment.draft_id = ?", draft_id }
    :exec()

  for i, draft_attachment in ipairs(draft_attachments) do
    if param.get("file_delete_" .. draft_attachment.file_id, atom.boolean) then
      draft_attachment:destroy()
    end
  end

  local file_uploads = json.array()
  local filename = encode.file_path(WEBMCP_BASE_PATH, 'tmp', "file_upload-" .. file_upload_session .. ".json")
  local fh = io.open(filename, "r")
  if fh then
    file_uploads = json.import(fh:read("*a"))
  end
  for i, file_upload in ipairs(file_uploads) do
    local filename = encode.file_path(WEBMCP_BASE_PATH, 'tmp', "file_upload-" .. file_upload_session .. "-" .. file_upload.id .. ".jpg")
    local data
    local fh = io.open(filename, "r")
    if fh then
      data = fh:read("*a")
    end
    local filename = encode.file_path(WEBMCP_BASE_PATH, 'tmp', "file_upload-" .. file_upload_session .. "-" .. file_upload.id .. ".preview.jpg")
    local data_preview
    local fh = io.open(filename, "r")
    if fh then
      data_preview = fh:read("*a")
    end

    local hash = moonhash.sha3_512(data)

    local file = File:new_selector()
      :add_where{ "hash = ?", hash }
      :add_where{ "content_type = ?", "image/jpeg" }
      :optional_object_mode()
      :exec()

    if not file then
      file = File:new()
      file.content_type = "image/jpeg"
      file.hash = hash
      file.data = data
      file.preview_content_type = "image/jpeg"
      file.preview_data = data_preview
      file:save()
    end

    local draft_attachment = DraftAttachment:new()
    draft_attachment.draft_id = draft_id
    draft_attachment.file_id = file.id
    draft_attachment.title = file_upload.title
    draft_attachment.description = file_upload.description
    draft_attachment:save()
  end
end

return draft_id and true or false
