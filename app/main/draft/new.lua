local issue
local area
local area_id

local issue_id = param.get("issue_id", atom.integer)
if issue_id then
  issue = Issue:new_selector():add_where{"id=?",issue_id}:single_object_mode():exec()
  issue:load_everything_for_member_id(app.session.member_id)
  area = issue.area
else
  area_id = param.get("area_id", atom.integer)
  if area_id then
    area = Area:new_selector():add_where{"id=?",area_id}:single_object_mode():exec()
    area:load_delegation_info_once_for_member_id(app.session.member_id)
  end
end

local polling = param.get("polling", atom.boolean)

local policy_id = param.get("policy_id", atom.integer)
local policy

local preview = param.get("preview")

if #(slot.get_content("error")) > 0 then
  preview = false
end

if policy_id then
  policy = Policy:by_id(policy_id)
end

local callback = param.get("callback")


local initiative_id = param.get("initiative_id")
local initiative = Initiative:by_id(initiative_id)
local draft
if initiative then
  initiative:load_everything_for_member_id(app.session.member_id)
  initiative.issue:load_everything_for_member_id(app.session.member_id)

  if initiative.issue.closed then
    slot.put_into("error", _"This issue is already closed.")
    return
  elseif initiative.issue.half_frozen then 
    slot.put_into("error", _"This issue is already frozen.")
    return
  elseif initiative.issue.phase_finished then
    slot.put_into("error", _"Current phase is already closed.")
    return
  end

  draft = initiative.current_draft
  if config.initiative_abstract then
    draft.abstract = string.match(draft.content, "(.+)<!%--END_OF_ABSTRACT%-->")
    if draft.abstract then
      draft.content = string.match(draft.content, "<!%--END_OF_ABSTRACT%-->(.*)")
    end
  end
end

if not initiative and not issue and not area then
  ui.heading{ content = _"Missing parameter" }
  return false
end

ui.form{
  record = draft,
  attr = { class = "vertical section", enctype = 'multipart/form-data' },
  module = "draft",
  action = "add",
  params = {
    area_id = area and area.id,
    issue_id = issue and issue.id or nil,
    initiative_id = initiative_id,
    callback = callback
  },
  routing = {
    ok = {
      mode = "redirect",
      module = "initiative",
      view = "show",
      id = initiative_id
    }
  },
  content = function()
  
    ui.grid{ content = function()
      ui.cell_main{ content = function()
        ui.container{ attr = { class = "mdl-card mdl-shadow--2dp mdl-card__fullwidth" }, content = function()
          ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
            if initiative then
              ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = initiative.display_name }
            elseif param.get("name") then
              ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = param.get("name") }
            elseif issue then
              ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _("New competing initiative in issue '#{issue}'", { issue = issue.name }) }
            elseif area then
              ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _("New issue in area '#{area}'", { area = area.name }) }
            end
          end }
          ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()

-- -------- PREVIEW
            if param.get("preview") then
              ui.sectionRow( function()
                if not issue and not initiative then
                  ui.container { content = policy.name }
                end
                if param.get("free_timing") then
                  ui.container { content = param.get("free_timing") }
                end
                slot.put("<br />")
                ui.field.hidden{ name = "policy_id", value = param.get("policy_id") }
                ui.field.hidden{ name = "name", value = param.get("name") }
                if config.initiative_abstract then
                  ui.field.hidden{ name = "abstract", value = param.get("abstract") }
                  ui.container{
                    attr = { class = "abstract" },
                    content = param.get("abstract")
                  }
                  slot.put("<br />")
                end
                local draft_text = param.get("content")
                local draft_text = util.wysihtml_preproc(draft_text)
                ui.field.hidden{ name = "content", value = draft_text }
                ui.container{
                  attr = { class = "draft" },
                  content = function()
                    slot.put(draft_text)
                  end
                }
                slot.put("<br />")

                if config.attachments then
                  local file_upload_session = param.get("file_upload_session") or multirand.string(
                    32,
                    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
                  )
                  file_upload_session = string.gsub(file_upload_session, "[^A-Za-z0-9]", "")
                  ui.field.hidden{ name = "file_upload_session", value = file_upload_session }
                  if initiative then
                     local files = File:new_selector()
                      :left_join("draft_attachment", nil, "draft_attachment.file_id = file.id")
                      :add_where{ "draft_attachment.draft_id = ?", initiative.current_draft.id }
                      :reset_fields()
                      :add_field("file.id")
                      :add_field("draft_attachment.title")
                      :add_field("draft_attachment.description")
                      :add_order_by("draft_attachment.id")
                      :exec()

                    if #files > 0 then
                      ui.container {
                        content = function()
                          for i, file in ipairs(files) do
                            if param.get("file_delete_" .. file.id, atom.boolean) then
                              ui.field.hidden{ name = "file_delete_" .. file.id, value = "1" }
                            else
                              ui.image{ module = "file", view = "show.jpg", id = file.id, params = { preview = true } }
                              ui.container{ content = function()
                                ui.tag{ tag = "strong", content = file.title or "" }
                              end }
                              ui.container{ content = file.description or "" }
                              slot.put("<br /><br />")
                            end
                          end
                        end
                      }
                    end
                  end
                  local filename = encode.file_path(WEBMCP_BASE_PATH, 'tmp', "file_upload-" .. file_upload_session .. ".json")
                  local fh = io.open(filename, "r")
                  if fh then
                    local file_uploads = json.import(fh:read("*a"))
                    for i, file_upload in ipairs(file_uploads) do
                      ui.image{ module = "draft", view = "show_file_upload", params = {
                        file_upload_session = file_upload_session, file_id = file_upload.id, preview = true
                      } }
                      ui.container{ content = function()
                        ui.tag{ tag = "strong", content = file_upload.title or "" }
                      end }
                      ui.container{ content = file_upload.description or "" }
                      slot.put("<br />")
                    end
                  end
                end

                ui.tag{
                  tag = "input",
                  attr = {
                    type = "submit",
                    class = "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--colored",
                    value = _'Publish now'
                  },
                  content = ""
                }
                slot.put(" &nbsp; ")

                ui.tag{
                  tag = "input",
                  attr = {
                    type = "submit",
                    name = "edit",
                    class = "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect",
                    value = _'Edit again'
                  },
                  content = ""
                }
                slot.put(" &nbsp; ")

                ui.link{
                  attr = { class = "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect" },
                  content = _"Cancel",
                  module = initiative and "initiative" or "area",
                  view = "show",
                  id = initiative_id or area_id
                }
              end )

-- -------- EDIT
            else

              if not issue_id and not initiative_id then
                local tmp = { { id = -1, name = "" } }
                for i, allowed_policy in ipairs(area.allowed_policies) do
                  if not allowed_policy.polling or app.session.member:has_polling_right_for_unit_id(area.unit_id) then
                    tmp[#tmp+1] = allowed_policy
                  end
                end
                ui.container{ content = _"Please choose a policy for the new issue:" }
                ui.field.select{
                  name = "policy_id",
                  foreign_records = tmp,
                  foreign_id = "id",
                  foreign_name = "name",
                  value = param.get("policy_id", atom.integer) or area.default_policy and area.default_policy.id
                }
                if policy and policy.free_timeable then
                  local available_timings
                  if config.free_timing and config.free_timing.available_func then
                    available_timings = config.free_timing.available_func(policy)
                    if available_timings == false then
                      slot.put_into("error", "error in free timing config")
                      return false
                    end
                  end
                  ui.heading{ level = 4, content = _"Free timing:" }
                  if available_timings then
                    ui.field.select{
                      name = "free_timing",
                      foreign_records = available_timings,
                      foreign_id = "id",
                      foreign_name = "name",
                      value = param.get("free_timing")
                    }
                  else
                    ui.field.text{
                      name = "free_timing",
                      value = param.get("free_timing")
                    }
                  end
                end
              end

              if issue and issue.policy.polling and app.session.member:has_polling_right_for_unit_id(area.unit_id) then
                slot.put("<br />")
                ui.field.boolean{ name = "polling", label = _"No admission needed", value = polling }
              end

              if not initiative then
                ui.container{ attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label mdl-card__fullwidth" }, content = function ()
                  ui.field.text{
                    attr = { id = "lf-initiative__name", class = "mdl-textfield__input" },
                    label_attr = { class = "mdl-textfield__label", ["for"] = "lf-initiative__name" },
                    label = _"Title",
                    name  = "name",
                    value = param.get("name")
                  }
                end }
              end

              if config.initiative_abstract then
                ui.container { content = _"Enter abstract:" }
                ui.container{ attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--expandable mdl-textfield__fullwidth" }, content = function()
                  ui.field.text{
                    name = "abstract",
                    multiline = true, 
                    attr = { id = "abstract", style = "height: 20ex; width: 100%;" },
                    value = param.get("abstract")
                  }
                end }
              end
              
              ui.container { content = _"Enter your proposal and/or reasons:" }
              ui.field.wysihtml{
                name = "content",
                multiline = true, 
                attr = { id = "draft", style = "height: 50ex; width: 100%;" },
                value = param.get("content")
              }
              if not issue or issue.state == "admission" or issue.state == "discussion" then
                ui.container { content = _"You can change your text again anytime during admission and discussion phase" }
              else
                ui.container { content = _"You cannot change your text again later, because this issue is already in verfication phase!" }
              end

              slot.put("<br />")
              if config.attachments then
                local file_upload_session = param.get("file_upload_session") or multirand.string(
                  32,
                  '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
                )
                file_upload_session = string.gsub(file_upload_session, "[^A-Za-z0-9]", "")
                ui.field.hidden{ name = "file_upload_session", value = file_upload_session }
                if initiative then
                  local files = File:new_selector()
                    :left_join("draft_attachment", nil, "draft_attachment.file_id = file.id")
                    :add_where{ "draft_attachment.draft_id = ?", initiative.current_draft.id }
                    :reset_fields()
                    :add_field("file.id")
                    :add_field("draft_attachment.title")
                    :add_field("draft_attachment.description")
                    :add_order_by("draft_attachment.id")
                    :exec()

                  if #files > 0 then
                    ui.container {
                      content = function()
                        for i, file in ipairs(files) do
                          ui.image{ module = "file", view = "show.jpg", id = file.id, params = { preview = true } }
                          ui.container{ content = function()
                            ui.tag{ tag = "strong", content = file.title or "" }
                          end }
                          ui.container{ content = file.description or "" }
                          ui.field.boolean{ label = _"delete", name = "file_delete_" .. file.id, value = param.get("file_delete_" .. file.id) and true or false }
                          slot.put("<br /><br />")
                        end
                      end
                    }
                  end
                end
                local filename = encode.file_path(WEBMCP_BASE_PATH, 'tmp', "file_upload-" .. file_upload_session .. ".json")
                local fh = io.open(filename, "r")
                if fh then
                  local file_uploads = json.import(fh:read("*a"))
                  for i, file_upload in ipairs(file_uploads) do
                    ui.image{ module = "draft", view = "show_file_upload", params = {
                      file_upload_session = file_upload_session, file_id = file_upload.id, preview = true
                    } }
                    ui.container{ content = function()
                      ui.tag{ tag = "strong", content = file_upload.title or "" }
                    end }
                    ui.container{ content = file_upload.description or "" }
                    ui.field.boolean{ label = _"delete", name = "file_upload_delete_" .. file_upload.id }
                    slot.put("<br />")
                  end
                end
                ui.container{ attr = { id = "file_upload_template", style = "display: none;" }, content = function()
                  ui.field.text{ label = _"Title", name = "__ID_title__" }
                  ui.field.text{ label = _"Description", name = "__ID_description__" }
                  ui.field.image{ field_name = "__ID_file__" }
                end }
                ui.container{ attr = { id = "file_upload" }, content = function()
                end }
                ui.field.hidden{ attr = { id = "file_upload_last_id" }, name = "file_upload_last_id" }
                ui.script{ script = [[ var file_upload_id = 1; ]] }
                ui.tag{ tag = "a", content = _"Attach image", attr = { 
                  href = "#",
                  onclick = "var html = document.getElementById('file_upload_template').innerHTML; html = html.replace('__ID_file__', 'file_' + file_upload_id); html = html.replace('__ID_title__', 'title_' + file_upload_id); html = html.replace('__ID_description__', 'description_' + file_upload_id); var el = document.createElement('div'); el.innerHTML = html; document.getElementById('file_upload').appendChild(el); document.getElementById('file_upload_last_id').value = file_upload_id; file_upload_id++; return false;"
                } }
                slot.put("<br />")
                
                slot.put("<br />")

              end

              ui.tag{
                tag = "input",
                attr = {
                  type = "submit",
                  name = "preview",
                  class = "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--colored",
                  value = _'Preview'
                },
                content = ""
              }
              slot.put(" &nbsp; ")
              
              ui.link{
                content = _"Cancel",
                module = initiative and "initiative" or issue and "issue" or "index",
                view = area and not issue and "index" or "show",
                id = initiative_id or issue_id,
                params = { area = area_id, unit = area and area.unit_id or nil },
                attr = { class = "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect" }
              }
              
            end
          end }
        end }
      end }

      if config.map or config.firstlife then
        ui.cell_sidebar{ content = function()
          ui.container{ attr = { class = "mdl-special-card map mdl-shadow--2dp" }, content = function()
            ui.field.location{ name = "location", value = param.get("location") }
          end }
        end }
      end

    end }
  end
}
