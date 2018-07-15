ui.titleMember(_"Connected applications")

ui.grid{ content = function()
  ui.cell_main{ content = function()

    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Connected applications" }
      end }

      local applications = MemberApplication:by_member_id(app.session.member_id)
      
      for i, application in ipairs(applications) do
        ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
          if application.system_application_id then
            ui.heading{ level = 2, content = application.system_application.name }
          else
            ui.heading{ level = 2, content = application.domain }
          end
          local scopes = {}
          for scope in string.gmatch(application.scope, "[^ ]+") do
            scopes[#scopes+1] = util.scope_name(scope)
          end
          local scopes_string = table.concat(scopes, ", ")
          ui.container{ content = scopes_string }
          ui.link{ content = _"Remove application", module = "member", action = "remove_application", id = application.id }
        end }
      end
    
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
