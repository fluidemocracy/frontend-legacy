ui.tag{
  tag = "noscript",
  content = function()
    slot.put(_"JavaScript is disabled or not available.")
  end
}

ui.title(_"Login [headline]")
app.html_title.title = _"Login [headline]"

ui.container{ attr = { class = "mdl-grid" }, content = function()
  ui.container{ attr = { class = "mdl-cell mdl-cell--12-col" }, content = function()
    execute.view{ module = "index", view = "_sidebar_motd_public" }

    execute.view{ module = "index", view = "_lang_chooser" }

    ui.heading{ level = 1, content = _"Login [headline]" }

    local redirect_params = {}
    local redirect_params_string = param.get("redirect_params") 

    if redirect_params_string then
      local tmp = json.import(redirect_params_string)
      if type(tmp) == "table" then
        for k, v in pairs(tmp) do
          if type(v) == "string" then
            redirect_params[k] = v
          end
        end
      end
    end

    ui.form{
      module = 'index',
      action = 'login',
      routing = {
        ok = {
          mode   = 'redirect',
          module = param.get("redirect_module") or "index",
          view = param.get("redirect_view") or "index",
          id = param.get("redirect_id"),
          params = redirect_params
        },
        error = {
          mode   = 'redirect',
          module = "index",
          view = "login",
          params = {
      redirect_module = param.get("redirect_module"),
      redirect_view   = param.get("redirect_view"),
      redirect_id     = param.get("redirect_id"),
      redirect_params = param.get("redirect_params")
          }
        }
      },
      content = function()
        if slot.get_content("error_code") == "invalid_credentials" then
          ui.container{ attr = { class = "warning" }, content = _"Invalid login name or password!" }
        end
        ui.field.text{
          container_attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label" },
          attr = { id = "lf-login__username", class = "mdl-textfield__input" },
          label_attr = { class = "mdl-textfield__label", ["for"] = "lf-login__username" },
          label     = _'Login name',
          name = 'login',
          value     = ''
        }
        slot.put("<br />")
        ui.field.password{
          container_attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label" },
          attr = { id = "lf-login__password", class = "mdl-textfield__input" },
          label_attr = { class = "mdl-textfield__label", ["for"] = "lf-login__password" },
          label     = _'Password',
          name = 'password',
          value     = ''
        }
        slot.put("<br /><br />")
        ui.tag{
          tag = "input",
          attr = {
            type = "submit",
            class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored",
            value = _"Login [button]"
          }
        }
        slot.put(" &nbsp; ")
        ui.link{ 
          attr = { class = "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect" },
          module = "index", view = "index", text = _"Cancel"
        }
        if not config.disable_registration then
          slot.put(" &nbsp; ")
          ui.link{ 
            attr = { class = "mdl-button mdl-js-button mdl-js-ripple-effect mdl-button--underlined" },
            module = "index", view = "register", text = _"No account yet?", params = {
              redirect_module = param.get("redirect_module"),
              redirect_view = param.get("redirect_view"),
              redirect_id = param.get("redirect_id"),
              redirect_params = param.get("redirect_params")
            } 
          }
        end
        if config.self_registration then
          slot.put(" &nbsp; ")
          ui.link{ 
            attr = { class = "mdl-button mdl-js-button mdl-js-ripple-effect mdl-button--underlined" },
            module = "registration", view = "register", text = _"No account yet?", params = {
              redirect_module = param.get("redirect_module"),
              redirect_view = param.get("redirect_view"),
              redirect_id = param.get("redirect_id"),
              redirect_params = param.get("redirect_params")
            } 
          }
        end
        if not (config.hide_reset_password and config.hide_recover_login) then
          slot.put("<br /><br />")
        end
        if not config.hide_reset_password then
            ui.link{
            attr = { class = "mdl-button mdl-js-button mdl-js-ripple-effect mdl-button--underlined" },
            module = "index", view = "reset_password", text = _"Forgot password?", params = {
              redirect_module = param.get("redirect_module"),
              redirect_view = param.get("redirect_view"),
              redirect_id = param.get("redirect_id"),
              redirect_params = param.get("redirect_params")
            }
          }
          slot.put(" &nbsp; ")
        end
        if not config.hide_recover_login then
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
      end
    }
  end }
end }
