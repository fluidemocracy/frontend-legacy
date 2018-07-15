ui.titleMember(_"avatar/photo")

ui.grid{ content = function()
  ui.cell_main{ content = function()

    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Upload avatar/photo" }
      end }
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()

        ui.form{
          record = app.session.member,
          attr = { 
            class = "vertical section",
            enctype = 'multipart/form-data'
          },
          module = "member",
          action = "update_images",
          routing = {
            ok = {
              mode = "redirect",
              module = "member",
              view = "settings"
            }
          },
          content = function()
            execute.view{
              module = "member_image",
              view = "_show",
              params = {
                class = "float-right",
                member = app.session.member, 
                image_type = "avatar",
                force_update = true
              }
            }
            ui.heading { level = 4, content = _"Avatar"}
            ui.container { content = _"Your avatar is a small photo, which will be shown always next to your name." }
            slot.put("<br />")
            ui.field.image{ field_name = "avatar" }

            execute.view{
              module = "member_image",
              view = "_show",
              params = {
                class = "float-right",
                member = app.session.member, 
                image_type = "photo",
                force_update = true
              }
            }
            ui.heading { level = 4, content = _"Photo"}
            ui.container { content = _"Your photo will be shown in your profile." }
            slot.put("<br />")
            ui.field.image{ field_name = "photo" }
            slot.put("<br style='clear: right;' />")
            ui.tag{
              tag = "input",
              attr = {
                type = "submit",
                class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored",
                value = _"publish avatar/photo"
              },
              content = ""
            }
            slot.put(" &nbsp; ")
            ui.link{
              attr = { class = "mdl-button mdl-js-button mdl-button--raised" },
              content = _"cancel",
              module = "member", view = "settings"
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
