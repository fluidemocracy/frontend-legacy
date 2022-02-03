local id = param.get("id")

if not id then
  return
end

local issue = Issue:by_id(id)
issue:load_everything_for_member_id ( app.session.member_id )
issue.initiatives:load_everything_for_member_id ( app.session.member_id )

ui.titleAdmin(_"Cancel issue")

ui.grid{ content = function()

  ui.cell_main{ content = function()
    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"public administrative notice:" }
      end }
      ui.container{ attr = { class = "mdl-card__content" }, content = function()

        ui.form{
          module = "admin",
          action = "cancel_issue",
          id = id,
          attr = { class = "vertical section" },
          content = function()
            
            ui.sectionRow( function()
              ui.field.text{ name = "admin_notice", multiline = true }
              ui.tag{
                tag = "input",
                attr = {
                  type = "submit",
                  class = "mdl-button mdl-js-button mdl-button--raised",
                  value = _"cancel issue now"
                }
              }
              slot.put(" &nbsp; ")
              ui.link {
                attr = { class = "mdl-button mdl-js-button mdl-js-ripple-effect mdl-button--underlined" },
                module = "admin", view = "index", content = _"do nothing"
               }
            end )
          end
        }
      end }
    end }
  end }

  ui.cell_sidebar{ content = function()

    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _("Issue ##{id}", { id = issue.id }) }
      end }
      execute.view{ module = "initiative", view = "_list", params = {
        issue = issue,
        initiatives = issue.initiatives
      } }
    end }
  end }


end }

