local return_to = param.get("return_to")
local return_to_area_id = param.get("return_to_area_id", atom.integer)
local return_to_area = Area:by_id(return_to_area_id)

ui.titleMember(_"notification settings")

ui.grid{ content = function()
  ui.cell_main{ content = function()

    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"notification settings" }
      end }
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()

        ui.form{
          attr = { class = "vertical" },
          module = "member",
          action = "update_notify_level",
          routing = {
            ok = {
              mode = "redirect",
              module = return_to == "area" and "index" or return_to == "home" and "index" or "member",
              view = return_to == "area" and "index" or return_to == "home" and "index" or "settings",
              params = return_to_area and { unit = return_to_area.unit_id, area = return_to_area.id } or nil
            }
          },
          content = function()
            
            ui.container{ content = function()
              ui.tag{ tag = "label", attr = {
                  class = "mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect",
                  ["for"] = "notify_level_all"
                },
                content = function()
                  ui.tag{
                    tag = "input",
                    attr = {
                      id = "notify_level_all",
                      class = "mdl-checkbox__input",
                      type = "checkbox", name = "enable_notifications", value = "true",
                      checked = not app.session.member.disable_notifications and "checked" or nil,
                      onchange = [[ display = document.getElementById("view_on_notify_level_all_false").style.display = this.checked ? "block" : "none"; ]]
                    }
                  }
                  ui.tag{
                    attr = { class = "mdl-checkbox__label", ['for'] = "notify_level_all" },
                    content = _"I like to receive notifications"
                  }
                end
              }
            end }
            
            
            ui.container{ attr = { id = "view_on_notify_level_all_false" }, content = function()
              slot.put("<br />")
            
              ui.container{ content = _"You will receive status update notification on issue phase changes. Additionally you can subscribe for a regular digest including updates on initiative drafts and new suggestions." }
              slot.put("<br />")
              ui.container{ content = function()
                ui.tag{ tag = "label", attr = {
                    class = "mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect",
                    ["for"] = "digest_on"
                  },
                  content = function()
                    ui.tag{
                      tag = "input", 
                      attr = {
                        id = "digest_on",
                        class = "mdl-checkbox__input",
                        type = "checkbox", name = "digest", value = "true",
                        checked = app.session.member.notification_hour ~= nil and "checked" or nil,
                        onchange = [[ display = document.getElementById("view_on_digest_true").style.display = this.checked ? "block" : "none"; ]]
                      }
                    }
                    ui.tag{
                      attr = { class = "mdl-checkbox__label", ['for'] = "digest_on" },
                      content = _"I want to receive a regular digest"
                    }
                  end
                }
              end }
          
              ui.container{ attr = { id = "view_on_digest_true", style = "margin-left: 4em;" }, content = function()

                ui.tag{ content = _"every" }
                slot.put(" ")
                ui.field.select{
                  container_attr = { style = "display: inline-block; vertical-align: middle;" },
                  attr = { style = "width: 10em;" },
                  name = "notification_dow",
                  foreign_records = {
                    { id = "daily", name = _"day" },
                    { id = 0, name = _"Sunday" },
                    { id = 1, name = _"Monday" },
                    { id = 2, name = _"Tuesday" },
                    { id = 3, name = _"Wednesday" },
                    { id = 4, name = _"Thursday" },
                    { id = 5, name = _"Friday" },
                    { id = 6, name = _"Saturday" }
                  },
                  foreign_id = "id",
                  foreign_name = "name",
                  value = app.session.member.notification_dow
                }
                
                slot.put(" ")

                ui.tag{ content = _"between" }
                slot.put(" ")
                local foreign_records = {}
                for i = 0, 23 do
                  foreign_records[#foreign_records+1] = {
                    id = i,
                    name = string.format("%02d:00 - %02d:59", i, i),
                  }
                end
                local random_hour
                if app.session.member.disable_notifications or app.session.member.notification_hour == nil then
                  random_hour = multirand.integer(0,23)
                end
                ui.field.select{
                  container_attr = { style = "display: inline-block; vertical-align: middle;" },
                  attr = { style = "width: 10em;" },
                  name = "notification_hour",
                  foreign_records = foreign_records,
                  foreign_id = "id",
                  foreign_name = "name",
                  value = random_hour or app.session.member.notification_hour
                }
              end }

            end }
            
            slot.put("<br />")
            
            if app.session.member.disable_notifications then
              ui.script{ script = [[ document.getElementById("view_on_notify_level_all_false").style.display = "none"; ]] }
            end
            
            if app.session.member.notification_hour == nil  then
              ui.script{ script = [[ document.getElementById("view_on_digest_true").style.display = "none"; ]] }
            end
   
            slot.put("<br />")
          
            ui.tag{
              tag = "input",
              attr = {
                type = "submit",
                class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored",
                value = _"Save"
              },
              content = ""
            }
            slot.put(" &nbsp; ")
            
            slot.put(" ")
            if return_to == "home" then
              ui.link {
                attr = { class = "mdl-button mdl-js-button mdl-button--raised" },
                module = "index", view = "index",
                content = _"cancel"
              }
            else
              ui.link {
                attr = { class = "mdl-button mdl-js-button mdl-button--raised" },
                module = "member", view = "settings", 
                content = _"cancel"
              }
            end
            
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
