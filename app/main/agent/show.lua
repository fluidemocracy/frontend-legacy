local controlled_id = param.get("controlled_id")


ui.titleMember(_"Account access")

ui.grid{ content = function()

  ui.cell_main{ content = function()
    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Account access" }
      end }
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
      
        local agent = Agent:new_selector()
          :add_where{ "controller_id = ?", app.session.member_id }
          :add_where{ "controlled_id = ?", controlled_id }
          :optional_object_mode()
          :exec()

        if agent then
          
          if agent.accepted == nil then
            ui.container{ content = _"You have been granted access privileges for the following account:" }
          elseif agent.accepted == true then
            ui.container{ content = _"You have accepted access privileges for the following account:" }
          elseif agent.accepted == false then
            ui.container{ content = _"You have rejected access privileges for the following account:" }
          end
          
          slot.put("<br>")
          ui.link{
            content = agent.controllee.display_name,
            module = "member", view = "show", id = agent.controlled_id
          }
          slot.put("<br><br>")
      
          ui.form{
            attr = { class = "wide" },
            module = "agent",
            action = "accept",
            params = { controlled_id = controlled_id },
            routing = {
              ok = {
                mode = "redirect",
                module = "agent",
                view = "show",
                params = { controlled_id = controlled_id },
              }
            },
            content = function()
            
              if agent.accepted == nil then
                ui.tag{
                  tag = "input",
                  attr = {
                    type = "submit",
                    class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored",
                    value = _"Accept access privilege",
                    name = "accepted"
                  },
                  content = ""
                }
                slot.put(" &nbsp; ")
                ui.tag{
                  tag = "input",
                  attr = {
                    type = "submit",
                    class = "mdl-button mdl-js-button mdl-button--raised",
                    value = _"Reject access privilege",
                    name = "rejected"
                  },
                  content = ""
                }
              end
              slot.put(" &nbsp; ")
              ui.link {
                attr = { class = "mdl-button mdl-js-button" },
                module = "index", view = "index",
                content = _"Cancel"
              }
            end
          }

        end

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
      
