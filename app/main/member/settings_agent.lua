if not app.session.member.role then
  return
end

ui.titleMember(_"Account access")

ui.grid{ content = function()

  ui.cell_main{ content = function()
    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Agents" }
      end }
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
      
        local agents = Agent:new_selector()
          :add_where{ "controlled_id = ?", app.session.member_id }
          :exec()
          
        if #(agents) > 0 then
          ui.list{
            records = agents,
            columns = {
              {
                label = _"Account access by member",
                content = function(record)
                  ui.tag{ content = record.controller.name }
                end
              },
              {
                label = _"Status",
                content = function(record)
                  local text
                  if record.accepted then
                    text = _"accepted [account access]"
                  elseif record.accepted == false then
                    text = _"rejected [account access]"
                  else
                    text = _"not decided yet"
                  end
                  ui.tag{ content = text }
                end
              },
              {
                content = function(record)
                  ui.link{ content = _"Revoke", module = "member", action = "update_agent", params = { delete = true, controller_id = record.controller_id } }
                end
              },
            }
          }
        else
          ui.container{ content = _"No other members are allowed to use this account." }
        end
      
      end }
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()

        ui.form{
          attr = { class = "wide" },
          module = "member",
          action = "update_agent",
          routing = {
            ok = {
              mode = "redirect",
              module = "member",
              view = "settings_agent"
            }
          },
          content = function()
          
            ui.container{ content = _"Add new account access privilege" }
          
            local contact_members = Member:build_selector{
              is_contact_of_member_id = app.session.member_id,
              active = true,
              order = "name"
            }:add_where("NOT member.role"):exec()

            ui.field.select{
              name = "controller_id",
              foreign_records = contact_members,
              foreign_id = "id",
              foreign_name = "name"
            }            
            slot.put("<br />")
            
            ui.tag{
              tag = "input",
              attr = {
                type = "submit",
                class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored",
                value = _"Grant account access"
              },
              content = ""
            }
            slot.put(" &nbsp; ")
              ui.link{
                attr = {
                  class = "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect",
                },
                content = _"cancel",
                module = "member", view = "show", id = app.session.member.id
              }
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
      
