local initiative = Initiative:by_id(param.get("initiative_id"))
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

local draft = initiative.current_draft
if config.initiative_abstract then
  draft.abstract = string.match(draft.content, "(.+)<!%--END_OF_ABSTRACT%-->")
  if draft.abstract then
    draft.content = string.match(draft.content, "<!%--END_OF_ABSTRACT%-->(.*)")
  end
end

ui.form{
  record = draft,
  attr = { class = "vertical section", enctype = 'multipart/form-data' },
  module = "draft",
  action = "add",
  params = { initiative_id = initiative.id },
  routing = {
    ok = {
      mode = "redirect",
      module = "initiative",
      view = "show",
      id = initiative.id
    }
  },
  content = function()
  
    ui.grid{ content = function()
      ui.cell_main{ content = function()
        ui.container{ attr = { class = "mdl-card mdl-shadow--2dp mdl-card__fullwidth" }, content = function()
          ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
            ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = initiative.display_name }
          end }
          ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
            if param.get("preview") then
              ui.sectionRow( function()
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
                            ui.container{ content = file.title or "" }
                            ui.container{ content = file.description or "" }
                            slot.put("<br /><br />")
                          end
                        end
                      end
                    }
                  end
                  local filename = encode.file_path(WEBMCP_BASE_PATH, 'tmp', "file_upload-" .. file_upload_session .. ".json")
                  local fh = io.open(filename, "r")
                  if fh then
                    local file_uploads = json.import(fh:read("*a"))
                    for i, file_upload in ipairs(file_uploads) do
                      ui.image{ module = "draft", view = "show_file_upload", params = {
                        file_upload_session = file_upload_session, file_id = file_upload.id, preview = true
                      } }
                      ui.container{ content = file_upload.title or "" }
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
                  module = "initiative",
                  view = "show",
                  id = initiative.id
                }
              end )

            else
              ui.sectionRow( function()
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
                          ui.container{ content = file.title or "" }
                          ui.container{ content = file.description or "" }
                          ui.field.boolean{ label = _"delete", name = "file_delete_" .. file.id, value = param.get("file_delete_" .. file.id) and true or false }
                          slot.put("<br /><br />")
                        end
                      end
                    }
                  end

                  local filename = encode.file_path(WEBMCP_BASE_PATH, 'tmp', "file_upload-" .. file_upload_session .. ".json")
                  local fh = io.open(filename, "r")
                  if fh then
                    local file_uploads = json.import(fh:read("*a"))
                    for i, file_upload in ipairs(file_uploads) do
                      ui.image{ module = "draft", view = "show_file_upload", params = {
                        file_upload_session = file_upload_session, file_id = file_upload.id, preview = true
                      } }
                      ui.container{ content = file_upload.title or "" }
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
                  module = "initiative",
                  view = "show",
                  id = initiative.id,
                  attr = { class = "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect" }
                }
                
              end )
            end
          end }
        end }
      end }
    end }
  end
}
