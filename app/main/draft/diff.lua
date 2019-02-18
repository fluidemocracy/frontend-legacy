local old_draft_id = param.get("old_draft_id", atom.integer)
local new_draft_id = param.get("new_draft_id", atom.integer)
local initiative_id = param.get("initiative_id", atom.number)

if not old_draft_id 
  or not new_draft_id 
  or old_draft_id == new_draft_id
then
  slot.reset_all()
  slot.select("error", function()
    ui.tag{ content = _"Please choose two different versions of the draft to compare" }
  end )
  request.redirect{
    module = "initiative", view = "history", id = initiative_id
  }
  return
end

if old_draft_id > new_draft_id then
  old_draft_id, new_draft_id = new_draft_id, old_draft_id
end

local old_draft = Draft:by_id(old_draft_id)
local new_draft = Draft:by_id(new_draft_id)

local initiative = new_draft.initiative

if app.session.member then
  initiative:load_everything_for_member_id(app.session.member_id)
  initiative.issue:load_everything_for_member_id(app.session.member_id)
end


local old_draft_content = string.gsub(string.gsub(util.html_to_text(old_draft.content), "\n", " ###ENTER###\n"), " ", "\n")
local new_draft_content = string.gsub(string.gsub(util.html_to_text(new_draft.content), "\n", " ###ENTER###\n"), " ", "\n")

local key = multirand.string(24, "0123456789abcdefghijklmnopqrstuvwxyz")

local old_draft_filename = encode.file_path(WEBMCP_BASE_PATH, 'tmp', "diff-" .. key .. "-old.tmp")
local new_draft_filename = encode.file_path(WEBMCP_BASE_PATH, 'tmp', "diff-" .. key .. "-new.tmp")

local old_draft_file = assert(io.open(old_draft_filename, "w"))
old_draft_file:write(old_draft_content)
old_draft_file:write("\n")
old_draft_file:close()

local new_draft_file = assert(io.open(new_draft_filename, "w"))
new_draft_file:write(new_draft_content)
new_draft_file:write("\n")
new_draft_file:close()

local output, err, status = extos.pfilter(nil, "sh", "-c", "diff -a -U 1000000000 '" .. old_draft_filename .. "' '" .. new_draft_filename .. "' | grep --binary-files=text -v ^--- | grep --binary-files=text -v ^+++ | grep --binary-files=text -v ^@")

os.remove(old_draft_filename)
os.remove(new_draft_filename)

local last_state = "first_run"

local function process_line(line)
  local state_char = string.sub(line, 1, 1)
  local state
  if state_char == "+" then
    state = "added"
  elseif state_char == "-" then
    state = "removed"
  elseif state_char == " " then
    state = "unchanged"
  end
  local state_changed = false
  if state ~= last_state then
    if last_state ~= "first_run" then
      slot.put("</span> ")
    end
    last_state = state
    state_changed = true
    slot.put("<span class=\"diff_" .. tostring(state) .. "\">")
  end

  line = string.sub(line, 2, #line)
  if line ~= "###ENTER###" then
    if not state_changed then
      slot.put(" ")
    end
    --slot.put(encode.html(line))
    slot.put(line)
  else
    slot.put("<br />")
  end
end

execute.view{ module = "issue", view = "_head", params = { issue = initiative.issue } }

ui.grid{ content = function()
  ui.cell_main{ content = function()
    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()

      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function ()
        ui.heading { 
          attr = { class = "mdl-card__title-text" },
          content = function()
            ui.link{
              module = "initiative", view = "show", id = initiative.id,
              content = initiative.display_name
            }
          end
        }
        ui.container{ content = _("Comparision of revisions #{id1} and #{id2}", {
          id1 = old_draft.id,
          id2 = new_draft.id 
        } ) }
      end }

      if app.session.member_id and not new_draft.initiative.revoked then
        local supporter = app.session.member:get_reference_selector("supporters")
          :add_where{ "initiative_id = ?", new_draft.initiative_id }
          :optional_object_mode()
          :exec()
        if supporter and supporter.draft_id == old_draft.id and new_draft.id == initiative.current_draft.id then
          ui.container {
            attr = { class = "mdl-card__content mdl-card--no-bottom-pad mdl-card--notice" },
            content = _"The draft of this initiative has been updated!"
          }
          ui.container {
            attr = { class = "mdl-card__actions mdl-card--action-border  mdl-card--notice" },
            content = function ()
              ui.link{
                attr = { class = "mdl-button mdl-js-button mdl-button--raised" },
                text   = _"refresh my support",
                module = "initiative",
                action = "add_support",
                id     = new_draft.initiative.id,
                params = { draft_id = new_draft.id },
                routing = {
                  default = {
                    mode = "redirect",
                    module = "initiative",
                    view = "show",
                    id = new_draft.initiative.id
                  }
                }
              }

              slot.put(" &nbsp; ")
              
              ui.link{
                attr = { class = "mdl-button mdl-js-button mdl-button--raised" },
                text   = _"remove my support",
                module = "initiative",
                action = "remove_support",
                id     = new_draft.initiative.id,
                routing = {
                  default = {
                    mode = "redirect",
                    module = "initiative",
                    view = "show",
                    id = new_draft.initiative.id
                  }
                }
              }        

              slot.put(" &nbsp; ")
              
              ui.link{
                attr = { class = "mdl-button mdl-js-button" },
                text   = _"cancel",
                module = "initiative",
                view   = "show",
                id     = new_draft.initiative.id,
              }        
            end
          }
        end
      end

      ui.container {
        attr = { class = "draft mdl-card__content mdl-card--border" },
        content = function ()
          if not status then
            ui.field.text{ value = _"The drafts do not differ" }
          else
            ui.container{
              tag = "div",
              attr = { class = "diff" },
              content = function()
                output = output:gsub("[^\n\r]+", function(line)
                  process_line(line)
                end)
              end
            }
          end 
        end
      }
    end }
  end }
  ui.cell_sidebar{ content = function()

    execute.view{ module = "issue", view = "_sidebar", params = {
      initiative = initiative,
      issue = initiative.issue
    } }

    execute.view {
      module = "issue", view = "_sidebar_whatcanido",
      params = { initiative = initiative }
    }

    execute.view { 
      module = "issue", view = "_sidebar_members", params = {
        issue = initiative.issue, initiative = initiative
      }
    }
  end }
end }
