ui.title(_"Self registration")
app.html_title.title = _"Self registration"

slot.put("<style>select.is-invalid { border-color: #c00; }</style>")

ui.container{ attr = { class = "mdl-grid" }, content = function()
  ui.container{ attr = { class = "mdl-cell mdl-cell--12-col" }, content = function()

    ui.form{
      attr = { onsubmit = "document.getElementById('register_button').disabled = true;" },
      module = "registration", action = "register",
      enctype = 'multipart/form-data'
      routing = {
        error = { mode = "forward", module = "registration", view = "register" }
      },
      content = function()

        ui.container{ content = config.self_registration.info_top }

        execute.view{ module = "registration", view = "_register_form" }

        ui.container{
          attr = { class = "use_terms" },
          content = function()
            slot.put(config.use_terms)
          end
        }
        
        for i, checkbox in ipairs(config.use_terms_checkboxes) do
          ui.tag{ tag = "label", attr = {
              class = "mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect",
              ["for"] = "use_terms_checkbox_" .. checkbox.name
            },
            content = function()
              ui.tag{
                tag = "input",
                attr = {
                  type = "checkbox",
                  class = "mdl-checkbox__input",
                  id = "use_terms_checkbox_" .. checkbox.name,
                  name = "use_terms_checkbox_" .. checkbox.name,
                  value = "1",
                  style = "float: left;",
                  checked = param.get("use_terms_checkbox_" .. checkbox.name, atom.boolean) and "checked" or nil
                }
              }
              ui.tag{
                attr = { class = "mdl-checkbox__label" },
                content = function() slot.put(checkbox.html) end
              }
            end
          }
          slot.put("<br /><br />")
        end
      
        ui.container{ content = function()
          slot.put(config.self_registration.info_bottom)
        end }

        slot.put("<br />")

        ui.tag{
          tag = "input",
          attr = {
            id = "register_button",
            type = "submit",
            class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored",
            value = _"Proceed with registration"
          }
        }
        if config.self_registration.allow_bypass_checks then
          slot.put(" &nbsp; ")
          ui.tag{
            tag = "input",
            attr = {
              name = "manual_verification",
              id = "manual_verification_button",
              type = "submit",
              class = "mdl-button mdl-js-button mdl-js-ripple-effect mdl-button--underlined",
              value = _"Manual verification (w/o mobile)"
            }
          }
        end
        slot.put(" &nbsp; ")
        if config.self_registration.cancel_link then
          ui.link{ 
            attr = { class = "mdl-button mdl-js-button mdl-js-ripple-effect mdl-button--underlined" },
            external = config.self_registration.cancel_link, text = _"Cancel"
          }
        else
          ui.link{ 
            attr = { class = "mdl-button mdl-js-button mdl-js-ripple-effect mdl-button--underlined" },
            module = "index", view = "login", text = _"Cancel", params = {
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
