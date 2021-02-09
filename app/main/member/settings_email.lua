ui.titleMember(_"Email address")

ui.grid{ content = function()
  ui.cell_main{ content = function()

    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Email address for notifications" }
      end }
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()

        ui.form{
          attr = { class = "vertical" },
          module = "member",
          action = "update_email",
          routing = {
            ok = {
              mode = "redirect",
              module = "member",
              view = "settings"
            }
          },
          content = function()
            if app.session.member.notify_email then
              ui.field.text{ label = _"confirmed address", value = app.session.member.notify_email, readonly = true }
            end
            if app.session.member.notify_email_unconfirmed then
              ui.field.text{ label = _"unconfirmed address", value = app.session.member.notify_email_unconfirmed, readonly = true }
            end
            if app.session.member.notify_email or app.session.member.notify_email_unconfirmed then
              slot.put("<br />")
            end
            ui.heading { level = 4, content = _"Enter a new email address:" }
            ui.field.text{
              container_attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label" },
              attr = { id = "lf-member__notify_email", class = "mdl-textfield__input" },
              label_attr = { class = "mdl-textfield__label", ["for"] = "lf-member__notify_email" },
              label     = _'email address',
              name = 'email',
              value     = ''
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
