
ui.title(_"Reset password")

ui.container{ attr = { class = "mdl-grid" }, content = function()
  ui.container{ attr = { class = "mdl-cell mdl-cell--12-col" }, content = function()
    execute.view{ module = "index", view = "_lang_chooser" }

    ui.heading{ level = 1, content = _"Forgot password?" }

    local secret = param.get("secret")

    if not secret then
      ui.tag{
        tag = 'p',
        content = _'Please enter your login name. You will receive an email with a link to reset your password.'
      }
      ui.form{
        attr = { class = "vertical" },
        module = "index",
        action = "reset_password",
        routing = {
          default = {
            mode = "redirect",
            module = "index",
            view = "login", params = {
              redirect_module = param.get("redirect_module"),
              redirect_view = param.get("redirect_view"),
              redirect_id = param.get("redirect_id"),
              redirect_params = param.get("redirect_params") 
            }
          }
        },
        content = function()
          ui.field.text{
            container_attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label" },
            attr = { id = "lf-login__username", class = "mdl-textfield__input" },
            label_attr = { class = "mdl-textfield__label", ["for"] = "lf-login__username" },
            label     = _'Login name',
            name = 'login',
            value     = ''
          }
          slot.put("<br />")

          slot.put("<br /><br />")
          ui.tag{
            tag = "input",
            attr = {
              type = "submit",
              class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored",
                value = _"Request password reset link"
            }
          }
          slot.put(" &nbsp; ")
          ui.link{ 
            attr = { class = "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect" },
            module = "index", view = "login", text = _"Cancel", params = {
              redirect_module = param.get("redirect_module"),
              redirect_view = param.get("redirect_view"),
              redirect_id = param.get("redirect_id"),
              redirect_params = param.get("redirect_params")
            }
          }
          slot.put("<br /><br />")
          ui.link{
            attr = { class = "mdl-button mdl-js-button mdl-js-ripple-effect mdl-button--underlined" },
            module = "index", view = "send_login", text = _"Forgot login name?", params = {
            redirect_module = param.get("redirect_module"),
            redirect_view = param.get("redirect_view"),
            redirect_id = param.get("redirect_id"),
            redirect_params = param.get("redirect_params")
          }
          }
        end
      }

    else

      ui.form{
        attr = { class = "vertical" },
        module = "index",
        action = "reset_password",
        routing = {
          ok = {
            mode = "redirect",
            module = "index",
            view = "index"
          }
        },
        content = function()
          ui.tag{
            tag = 'p',
            content = _'Please enter the email reset code you have received:'
          }
          ui.field.text{
            label = _"Reset code",
            name = "secret",
            value = secret
          }
          ui.tag{
            tag = 'p',
            content = _'Please enter your new password twice.'
          }
          ui.field.password{
            label = "New password",
            name = "password1"
          }
          ui.field.password{
            label = "New password (repeat)",
            name = "password2"
          }
          
          ui.container { attr = { class = "actions" }, content = function()
            ui.tag{
              tag = "input",
              attr = {
                type = "submit",
                class = "btn btn-default",
                value = _"Save new password"
              },
              content = ""
            }
            slot.put("<br />")
            slot.put("<br />")

            ui.link{
              content = function()
                  slot.put(_"Cancel")
              end,
              module = "index",
              view = "login"
            }
          end }
        end
      }

    end
  end }
end }
