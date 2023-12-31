ui.titleMember(_"Edit your profile data")

local profile = app.session.member.profile

ui.grid{ content = function()
  ui.cell_main{ content = function()

    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Edit your profile data" }
      end }
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
        ui.form{
          record = profile,
          attr = { class = "vertical" },
          module = "member",
          action = "update",
          routing = {
            ok = {
              mode = "redirect",
              module = "member",
              view = "show",
              id = app.session.member_id
            }
          },
          content = function()
          
--            ui.container{ content = _"All fields are optional. Please enter only data which should be published." }
            
            if config.member_profile_fields then
              for i, field in ipairs(config.member_profile_fields) do
                ui.container{
                  attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label" },
                  content = function()
                    ui.tag{ tag = "input", attr = { class = "mdl-textfield__input", name = field.id, id = "input_" .. field.id, readonly = field.validate_func and "readonly" or nil, value = profile and profile.profile and profile.profile[field.id] or nil } }
                    ui.tag{ tag = "label", attr = { class = "mdl-textfield__label", ["for"] = "input_" .. field.id }, content = field.name }
                end }
                slot.put("<br />")
              end
            end
            ui.field.text{
              label = _"Statement",
              name = "statement",
              multiline = true, 
              attr = { style = "height: 50ex;" },
              value = param.get("statement")
            }
            slot.put("<br />")
            ui.container{ attr = { class = "actions" }, content = function()
              ui.tag{
                tag = "input",
                attr = {
                  type = "submit",
                  class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect",
                  value = _"publish profile data"
                },
                content = ""
              }
              slot.put(" &nbsp; ")
              ui.link {
                attr = { class = "mdl-button mdl-js-button" },
                module = "member", view = "show", id = app.session.member_id,
                content = _"Cancel"
              }
            end }
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
