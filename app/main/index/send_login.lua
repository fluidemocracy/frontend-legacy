ui.title(_"Recover login name")

ui.container{ attr = { class = "mdl-grid" }, content = function()
  ui.container{ attr = { class = "mdl-cell mdl-cell--12-col" }, content = function()
    execute.view{ module = "index", view = "_lang_chooser" }

    ui.heading{ level = 1, content = _"Forgot login name?" }

    ui.tag{
      tag = 'p',
      content = _'Please enter your email address. You will receive an email with your login name.'
    }

    ui.form{
      attr = { class = "vertical" },
      module = "index",
      action = "send_login",
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
          label     = _'Email address',
          name = 'email',
          value     = ''
        }
        slot.put("<br />")

        slot.put("<br /><br />")
        ui.tag{
          tag = "input",
          attr = {
            type = "submit",
            class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored",
              value = _"Request email with login name"
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
      end
    }
  end }
end }
