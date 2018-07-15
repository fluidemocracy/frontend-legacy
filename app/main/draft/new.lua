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
  attr = { class = "vertical section" },
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
