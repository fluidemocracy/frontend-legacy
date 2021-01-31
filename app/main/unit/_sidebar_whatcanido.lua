local unit = param.get ( "unit", "table" )
unit:load_delegation_info_once_for_member_id(app.session.member_id)

ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
  ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
    ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"What can I do here?" }
  end }
  ui.container{ attr = { class = "what-can-i-do-here" }, content = function()

    if app.session.member and app.session.member:has_voting_right_for_unit_id ( unit.id ) then
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
        ui.tag{ content = _"I want to stay informed" }
        ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
          ui.tag { tag = "li", content = function ()
            ui.tag{ content = _"check your " }
            ui.link{
              module = "member", view = "settings_notification",
              params = { return_to = "home" },
              text = _"notifications settings"
            }
          end }
          if not config.voting_only then
            ui.tag { tag = "li", content = function ()
              ui.tag{ content = _"subscribe subject areas or add your interested to issues and you will be notified about changes (follow the instruction on the area or issue page)" }
            end }
          end
        end } 
      end }

      if not config.disable_delegations then
        ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
          if not unit.delegation_info.first_trustee_id then
            ui.tag{ content = _"I want to delegate this organizational unit" }
            ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
              ui.tag { tag = "li", content = function ()
                ui.link {
                  module = "delegation", view = "show", params = {
                    unit_id = unit.id,
                  },
                  content = _("choose delegatee", {
                    unit_name = unit.name
                  })
                }
              end }
            end }
          else
            ui.tag{ content = _"You delegated this unit" }

            ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
              ui.tag { tag = "li", content = function ()
                ui.link {
                  module = "delegation", view = "show", params = {
                    unit_id = unit.id,
                  },
                  content = _("change/revoke delegation", {
                    unit_name = unit.name
                  })
                }
              end }
            end }
          end
        end }
      end
      
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
        ui.tag{
          content = _"I want to vote" 
        }
        ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
          ui.tag { tag = "li", content = _"check the issues on the right, and click on 'Vote now' to vote on an issue which is in voting phase." }
        end }
      end }

    else
      ui.container { attr = { class = "mdl-card__content mdl-card--border" }, content = function ()
        ui.tag{ content = _"You are not entitled to vote in this unit" }
        if not app.session.member_id then
          ui.tag{ tag = "ul", content = function()
            ui.tag{ tag = "li", content = function()
              ui.link{ module = "index", view = "login", content = _"Login" }
            end }
          end }
        end
      end }
    end
    
    if not config.voting_only and app.session.member_id and app.session.member:has_initiative_right_for_unit_id ( unit.id ) then
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
        ui.tag{ content = _"I want to start a new initiative" }
        ui.tag{ tag = "ul", attr = { class = "ul" }, content = function ()
          ui.tag { tag = "li", content = _"open the appropriate subject area for your issue and follow the instruction on that page." }
        end } 
      end }
    end
   
  end }
  
end }
