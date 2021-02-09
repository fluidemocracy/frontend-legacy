ui.titleMember(_"Password")

ui.grid{ content = function()
  ui.cell_main{ content = function()

    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Password" }
      end }
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()

        ui.form{
          attr = { class = "wide" },
          module = "member",
          action = "update_password",
          routing = {
            ok = {
              mode = "redirect",
              module = "member",
              view = "settings"
            }
          },
          content = function()

            ui.field.password{
              container_attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label" },
              attr = { id = "lf-member__old_password", class = "mdl-textfield__input" },
              label_attr = { class = "mdl-textfield__label", ["for"] = "lf-member__old_password" },
              label= _'Curent password',
              name = 'old_password',
              value = ""
            }

            slot.put("<br />")
            
            ui.field.password{
              container_attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label" },
              attr = { id = "lf-member__new_password1", class = "mdl-textfield__input" },
              label_attr = { class = "mdl-textfield__label", ["for"] = "lf-member__new_password1" },
              label= _'New password',
              name = 'new_password1',
              value = ""
            }

            slot.put("<br />")

            ui.field.password{
              container_attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label" },
              attr = { id = "lf-member__new_password2", class = "mdl-textfield__input" },
              label_attr = { class = "mdl-textfield__label", ["for"] = "lf-member__new_password2" },
              label= _'Repeat new password',
              name = 'new_password2',
              value = ""
            }

            slot.put("<br />")
            
            ui.tag{
              tag = "input",
              attr = {
          type = "submit",
          class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored",
          value = _"Save"
              },
              content = ""
            }
            slot.put(" &nbsp; ")
            ui.link {
              attr = { class = "mdl-button mdl-js-button" },
              module = "member", view = "show", id = app.session.member_id,
              content = _"Cancel"
            }
          end
        }
        
      end }
    end }
  end }

  ui.cell_sidebar{ content = function()
    execute.view {
      module = "member", view = "_sidebar_whatcanido", params = {
        member = app.session.member
      }
    }
  end }

end }
