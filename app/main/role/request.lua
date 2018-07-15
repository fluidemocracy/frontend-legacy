ui.titleMember(_"Request role account")

ui.grid{ content = function()

  ui.cell_main{ content = function()
    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Request role accounts" }
      end }
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()


        ui.form{
          attr = { onsubmit = "document.getElementById('register_button').disabled = true;" },
          module = "role", action = "request",
          routing = {
            error = { mode = "forward", module = "role", view = "request" }
          },
          content = function()

            ui.container{ content = config.role_registration.info_top }

            execute.view{ module = "role", view = "_request_form" }

            ui.container{
              attr = { class = "use_terms" },
              content = function()
                slot.put(config.use_terms_role)
              end
            }
            
            if config.use_terms_checkboxes_role then
              for i, checkbox in ipairs(config.use_terms_checkboxes_role) do
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
            end
            
            ui.container{ content = function()
              slot.put(config.role_registration.info_bottom)
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
            slot.put(" &nbsp; ")
            ui.link{ 
              attr = { class = "mdl-button mdl-js-button mdl-js-ripple-effect mdl-button--underlined" },
              module = "member", view = "show", id = app.session.member_id, text = _"Cancel", 
            }
      
        end }
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
      
