execute.view{ module = "index", view = "_lang_chooser" }

ui.grid{ content = function()
  ui.cell_main{ content = function()

    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Settings" }
      end }
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()

        local agents = Agent:new_selector()
          :add_where{ "controller_id = ?", app.session.member_id }
          :add_where{ "accepted ISNULL" }
          :exec()
          
        if #agents > 0 then
          ui.container { attr = { class = "mdl-card__content mdl-card--border" }, content = function ()
            ui.container{ content = _"You have been granted access to the following account(s):" }
            for i, agent in ipairs(agents) do
              local member = Member:by_id(agent.controlled_id)
              ui.tag { tag = "ul", content = function()
                ui.tag{ tag = "li", content = function()
                  ui.link{
                    module = "agent", view = "show", params = { controlled_id = agent.controlled_id },
                    content= _("Account access invitation from '#{member_name}'", { member_name = member.name })
                  }
                end }
              end }
            end
          end }
        end

      
        local controlled_members_count = Member:new_selector()
          :join("agent", nil, "agent.controlled_id = member.id")
          :add_where("agent.accepted")
          :add_where("NOT member.locked")
          :add_where{ "agent.controller_id = ?", app.session.member_id }
          :count()
        if controlled_members_count > 0 or app.session.real_member_id then
          ui.container { attr = { class = "mdl-card__content mdl-card--border" }, content = function ()
            ui.container{ content = _"I want to switch to another account" }
            ui.tag { tag = "ul", content = function()
              execute.view{ module = "member", view = "_agent_menu" }
            end }
          end }
        end
        
        execute.view{ module = "member", view = "_settings_list" }

      end }
    end }
  end }
end }
