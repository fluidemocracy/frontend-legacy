local return_to = param.get("return_to")

ui.titleMember(_"notification settings")

execute.view {
  module = "member", view = "_sidebar_whatcanido", params = {
    member = app.session.member
  }
}

ui.form{
  attr = { class = "vertical" },
  module = "member",
  action = "update_notify_level",
  routing = {
    ok = {
      mode = "redirect",
      module = return_to == "home" and "index" or "member",
      view = return_to == "home" and "index" or "show",
      id = return_to ~= "home" and app.session.member_id or nil
    }
  },
  content = function()

    ui.section( function()

      ui.sectionHead( function()
        ui.heading { level = 1, content = _"For which issue phases do you like to receive notification emails?" }
      end )

    
      ui.sectionRow( function()
      
        ui.container{ content = function()
          ui.tag{
            tag = "input", 
            attr = {
              id = "notify_level_all",
              type = "radio", name = "disable_notifications", value = "false",
              checked = not app.session.member.disable_notifications and "checked" or nil
            }
          }
          ui.tag{
            tag = "label", attr = { ['for'] = "notify_level_all" },
            content = _"I like to receive notifications"
          }
        end }
        
        slot.put("<br />")

        ui.container{ content = function()
          ui.tag{
            tag = "input", 
            attr = {
              id = "notify_level_none",
              type = "radio", name = "disable_notifications", value = "true",
              checked = app.session.member.disable_notifications and "checked" or nil
            }
          }
          ui.tag{
            tag = "label", attr = { ['for'] = "notify_level_none" },
            content = _"I do not like to receive notifications by email"
          }
        end }
        
        slot.put("<br />")
      
        ui.tag{
          tag = "input",
          attr = {
            type = "submit",
            class = "btn btn-default",
            value = _"Save"
          },
          content = ""
        }
        slot.put("<br /><br /><br />")
        
        slot.put(" ")
        if return_to == "home" then
          ui.link {
            module = "index", view = "index",
            content = _"cancel"
          }
        else
          ui.link {
            module = "member", view = "show", id = app.session.member_id, 
            content = _"cancel"
          }
        end
      end ) 
    end )
    
  end
}
 
