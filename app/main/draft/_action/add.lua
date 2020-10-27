local initiative
local new_initiative
local draft_id
local status

if param.get("initiative_id", atom.integer) then

  local function donew()
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

    draft_id = Draft:update_content(
      app.session.member.id, 
      param.get("initiative_id", atom.integer),
      param.get("formatting_engine"),
      draft_text,
      nil,
      param.get("preview") or param.get("edit")
    )
    return draft_id and true or false
  end

  status = donew()

else

  local function donew()
    local issue
    local area

    local issue_id = param.get("issue_id", atom.integer)
    if issue_id then
      issue = Issue:new_selector():add_where{"id=?",issue_id}:for_share():single_object_mode():exec()
      if issue.closed then
        slot.put_into("error", _"This issue is already closed.")
        return false
      elseif issue.fully_frozen then 
        slot.put_into("error", _"Voting for this issue has already begun.")
        return false
      elseif issue.phase_finished then
        slot.put_into("error", _"Current phase is already closed.")
        return false
      end
      area = issue.area
    else
      local area_id = param.get("area_id", atom.integer)
      area = Area:new_selector():add_where{"id=?",area_id}:single_object_mode():exec()
      if not area.active then
        slot.put_into("error", "Invalid area.")
        return false
      end
    end

    if not app.session.member:has_voting_right_for_unit_id(area.unit_id) then
      return execute.view { module = "index", view = "403" }
    end

    local policy_id = param.get("policy_id", atom.integer)
    local policy
    if policy_id then
      policy = Policy:by_id(policy_id)
    end

    if not issue then
      if policy_id == -1 then
        slot.put_into("error", _"Please choose a policy")
        return false
      end
      if not policy.active then
        slot.put_into("error", "Invalid policy.")
        return false
      end
      if policy.polling and not app.session.member:has_polling_right_for_unit_id(area.unit_id) then
        return execute.view { module = "index", view = "403" }
      end
      if not area:get_reference_selector("allowed_policies")
        :add_where{ "policy.id = ?", policy_id }
        :optional_object_mode()
        :exec()
      then
        slot.put_into("error", "policy not allowed")
        return false
      end
    end

    local is_polling = (issue and param.get("polling", atom.boolean)) or (policy and policy.polling) or false

    local tmp = db:query({ "SELECT text_entries_left, initiatives_left FROM member_contingent_left WHERE member_id = ? AND polling = ?", app.session.member.id, is_polling }, "opt_object")
    if not tmp or tmp.initiatives_left < 1 then
      slot.put_into("error", _"Sorry, your contingent for creating initiatives has been used up. Please try again later.")
      return false
    end
    if tmp and tmp.text_entries_left < 1 then
      slot.put_into("error", _"Sorry, you have reached your personal flood limit. Please be slower...")
      return false
    end

    local name = param.get("name")

    local name = util.trim(name)

    if #name < 3 then
      slot.put_into("error", _"Please enter a meaningful title for your initiative!")
      return false
    end

    if #name > 140 then
      slot.put_into("error", _"This title is too long!")
      return false
    end

    local timing
    if not issue and policy.free_timeable then
      local free_timing_string = util.trim(param.get("free_timing"))
      if not free_timing_string or #free_timing_string < 1 then
        slot.put_into("error", _"Choose timing")
        return false
      end
      local available_timings
      if config.free_timing and config.free_timing.available_func then
        available_timings = config.free_timing.available_func(policy)
        if available_timings == false then
          slot.put_into("error", "error in free timing config")
          return false
        end
      end
      if available_timings then
        local timing_available = false
        for i, available_timing in ipairs(available_timings) do
          if available_timing.id == free_timing_string then
      	    timing_available = true
          end
        end
        if not timing_available then
          slot.put_into("error", _"Invalid timing")
          return false
        end
      end
      timing = config.free_timing.calculate_func(policy, free_timing_string)
      if not timing then
        slot.put_into("error", "error in free timing config")
        return false
      end
    end

    local draft_text = param.get("content")

    if not draft_text then
      slot.put_into("error", "no draft text")
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
        slot.put_into("error", "no abstract")
        return false
      end
      abstract = encode.html(abstract)
      draft_text = abstract .. "<!--END_OF_ABSTRACT-->" .. draft_text
    end

    local location = param.get("location")
    if location == "" then
      location = nil
    end
    
    local external_reference
    if config.firstlife then
      external_reference = param.get("external_reference")
    end

    if param.get("preview") or param.get("edit") then
      return false
    end

    initiative = Initiative:new()

    if not issue then
      issue = Issue:new()
      issue.area_id = area.id
      issue.policy_id = policy_id
      
      if policy.polling then
        issue.accepted = 'now'
        issue.state = 'discussion'
        initiative.polling = true
        
        if policy.free_timeable then
          issue.discussion_time = timing.discussion
          issue.verification_time = timing.verification
          issue.voting_time = timing.voting
        end
        
      end
      
      issue:save()

      if config.etherpad then
        local result = net.curl(
          config.etherpad.api_base 
          .. "api/1/createGroupPad?apikey=" .. config.etherpad.api_key
          .. "&groupID=" .. config.etherpad.group_id
          .. "&padName=Issue" .. tostring(issue.id)
          .. "&text=" .. request.get_absolute_baseurl() .. "issue/show/" .. tostring(issue.id) .. ".html"
        )
      end
    end

    if param.get("polling", atom.boolean) and app.session.member:has_polling_right_for_unit_id(area.unit_id) then
      initiative.polling = true
    end
    initiative.issue_id = issue.id
    initiative.name = name
    initiative.external_reference = external_reference
    initiative:save()

    new_initiative = initiative

    local draft = Draft:new()
    draft.initiative_id = initiative.id
    draft.formatting_engine = formatting_engine
    draft.content = draft_text
    draft.location = location
    draft.author_id = app.session.member.id
    draft:save()

    draft_id = draft.id

    local initiator = Initiator:new()
    initiator.initiative_id = initiative.id
    initiator.member_id = app.session.member.id
    initiator.accepted = true
    initiator:save()

    if not is_polling then
      local supporter = Supporter:new()
      supporter.initiative_id = initiative.id
      supporter.member_id = app.session.member.id
      supporter.draft_id = draft.id
      supporter:save()
    end

  end
  status = donew()
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

  if draft_id then
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

end

if new_initiative and status ~= false then
  local callback = param.get("callback")
  if config.allow_new_draft_callback and callback then
    request.redirect{ external = callback }
  else
    request.redirect{
      module = "initiative",
      view = "show",
      id = new_initiative.id
    }
  end
end

return status

