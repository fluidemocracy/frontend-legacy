ui.title(_"Email address confirmation")

ui.grid{ content = function()
  ui.cell_full{ content = function()
    ui.container { attr = { class = "mdl-card mdl-shadow--2dp mdl-card__fullwidth" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Email address confirmation" }
      end }
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
        ui.form{
          attr = { class = "vertical" },
          module = "index",
          action = "confirm_notify_email",
          routing = {
            ok = {
              mode = "redirect",
              module = "index",
              view = "index"
            }
          },
          content = function()
            local secret = param.get("secret")
            if secret then
              ui.field.hidden{
                name = "secret",
                value = secret
              }
            else
              ui.field.text{
                label = _"Confirmation code",
                name = "secret"
              }
            end
            ui.tag{
              tag = "input",
              attr = {
                type = "submit",
                class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored",
                value = _'Confirm'
              }
            }
          end
        }

      end }
    end }
  end }
end }
