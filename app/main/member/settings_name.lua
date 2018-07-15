ui.titleMember(_"Screen name")

ui.grid{ content = function()

  ui.cell_main{ content = function()
    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Screen name" }
      end }
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()

        ui.form{
          attr = { class = "wide" },
          module = "member",
          action = "update_name",
          routing = {
            ok = {
              mode = "redirect",
              module = "member",
              view = "settings"
            }
          },
          content = function()
            ui.field.text{
              container_attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label" },
              attr = { id = "lf-member__name", class = "mdl-textfield__input" },
              label_attr = { class = "mdl-textfield__label", ["for"] = "lf-member__name" },
              label= _'Screen name',
              name = 'name',
              value = app.session.member.name
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
              attr = { class = "mdl-button mdl-js-button mdl-button--raised" },
              module = "member", view = "show", 
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
      
