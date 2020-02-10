local draft = Draft:new_selector():add_where{ "id = ?", param.get_id() }:optional_object_mode():exec()

if not draft then
  execute.view { module = "index", view = "404" }
  request.set_status("404 Not Found")
  return
end

local member = app.session.member

if member then
  draft.initiative:load_everything_for_member_id(member.id)
  draft.initiative.issue:load_everything_for_member_id(member.id)
end

local source = param.get("source", atom.boolean)

execute.view{ module = "issue", view = "_head", params = { issue = draft.initiative.issue, link_issue = true } }

ui.grid{ content = function()

  ui.cell_main{ content = function()

    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()

      ui.container{ attr = { class = "mdl-card__title mdl-card--has-fab mdl-card--border" }, content = function ()

        ui.heading { 
          attr = { class = "mdl-card__title-text" },
          level = 2,
          content = function()
            ui.link{
              module = "initiative", view = "show", id = draft.initiative.id,
              content = draft.initiative.display_name
            }
            ui.container{ content = _("Draft revision #{id}", { id = draft.id } ) }
          end 
        }
      end }

      ui.container{ attr = { class = "draft mdl-card__title mdl-card--border" }, content = function()
        if config.render_external_reference and config.render_external_reference.draft then
          config.render_external_reference.draft(draft, function (callback)
            ui.sectionRow(callback)
          end)
        end
        
        execute.view{
          module = "draft",
          view = "_show",
          params = { draft = draft, source = source }
        }



      end }      

      if config.attachments then

        local files = File:new_selector()
          :left_join("draft_attachment", nil, "draft_attachment.file_id = file.id")
          :add_where{ "draft_attachment.draft_id = ?", draft.id }
          :reset_fields()
          :add_field("file.id")
          :add_field("draft_attachment.title")
          :add_field("draft_attachment.description")
          :add_order_by("draft_attachment.id")
          :exec()

        if #files > 0 then
          ui.container {
            attr = { class = "mdl-card__content mdl-card--border" },
            content = function()
              for i, file in ipairs(files) do
                ui.link{ module = "file", view = "show.jpg", id = file.id, content = function()
                  ui.image{ module = "file", view = "show.jpg", id = file.id, params = { preview = true } }
                end }
                ui.container{ content = file.title or "" }
                ui.container{ content = file.description or "" }
                slot.put("<br /><br />")
              end
            end
          }
        end
      end

      ui.container{ attr = { class = "mdl-card__actions" }, content = function()
        if source then
          ui.link{
            attr = { class = "mdl-button mdl-js-button" },
            content = _"Rendered",
            module = "draft",
            view = "show",
            id = param.get_id(),
            params = { source = false }
          }
        else
          ui.link{
            attr = { class = "mdl-button mdl-js-button" },
            content = _"Source",
            module = "draft",
            view = "show",
            id = param.get_id(),
            params = { source = true }
          }
        end
        
      end }
    end }

  end }

  ui.cell_sidebar{ content = function()
    if config.logo then
      config.logo()
    end
    execute.view {
      module = "issue", view = "_sidebar", 
      params = {
        issue = draft.initiative.issue,
        initiative = draft.initiative,
        member = app.session.member
      }
    }
  end }

end }
