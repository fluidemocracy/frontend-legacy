local id = param.get_id()

local member = Member:by_id(id)

--ui.title(_"Deactivate member")

ui.titleAdmin(_"Member")

ui.grid{ content = function()

  ui.cell_main{ content = function()
    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Deactivate member" }
      end }
      ui.container{ attr = { class = "mdl-card__content" }, content = function()


        ui.form{
          attr = { class = "vertical section" },
          module = "admin",
          action = "member_deactivate",
          id = member and member.id,
          record = member,
          routing = {
            error = {
              mode = "forward",
              module = "admin", view = "member_deactivate", id = id
            },
            default = {
              mode = "redirect",
              modules = "admin", view = "index"
            }
          },
          content = function()

            ui.container{ content = _"Do you really want to irrevocably deactive this member?" }
            slot.put("<br>")
            ui.container{ content = _"ID" .. ": " .. member.id }
            ui.container{ content = _"Identification" .. ": " .. member.identification }
            ui.container{ content = _"Screen name" .. ": " .. member.name }
            slot.put("<br>")
            ui.tag{ tag = "input", attr = { type = "checkbox", name = "sure", value = "yes" } }
            ui.tag { content = _"I want to deactive this member irrevocably" }
            slot.put("<br />")
            slot.put("<br />")

            ui.submit{
              attr = { class = "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect" },
              text = _"Deactivate member"
            }
            slot.put(" ")
            ui.link {
              attr = { class = "mdl-button mdl-js-button" },
              module = "admin", view = "member_edit", id = member.id, content = _"cancel"
            }

          end
        }
      end }
    end }
  end }
end }

