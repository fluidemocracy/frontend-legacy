local area = param.get ( "area", "table" )
area:load_delegation_info_once_for_member_id(app.session.member_id)

local participating_trustee_id
local participating_trustee_name
if app.session.member then
  if area.delegation_info.first_trustee_participation then
    participating_trustee_id = area.delegation_info.first_trustee_id
    participating_trustee_name = area.delegation_info.first_trustee_name
  elseif area.delegation_info.other_trustee_participation then
    participating_trustee_id = area.delegation_info.other_trustee_id
    participating_trustee_name = area.delegation_info.other_trustee_name
  end
end

ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
  ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
    ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"What can I do here?" }
  end }
  ui.container{ attr = { class = "what-can-i-do-here" }, content = function()

    if app.session.member and app.session.member:has_voting_right_for_unit_id(area.unit_id) then
    
      if not app.session.member.disable_notifications then
        
        local ignored_area = IgnoredArea:by_pk(app.session.member_id, area.id)

        if not ignored_area then
          ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
            ui.tag{ content = _"You are receiving updates by email for this subject area" }
            ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
              ui.tag { tag = "li", content = function ()
                ui.tag { content = function ()
                  ui.link {
                    module = "area", action = "update_ignore",
                    params = { area_id = area.id },
                    routing = { default = {
                      mode = "redirect", module = "index", view = "index", params = { unit = area.unit_id, area = area.id }
                    } },
                    text = _"unsubscribe from update emails about this area"
                  }
                end }
              end }
            end }
          end }
        end
        
        if ignored_area then
          ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
            ui.tag{ content = _"I want to stay informed" }
            ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
              ui.tag { tag = "li", content = function ()
                ui.tag { content = function ()
                  ui.link {
                    module = "area", action = "update_ignore",
                    params = { area_id = area.id, delete = true },
                    routing = { default = {
                      mode = "redirect", module = "index", view = "index", params = { unit = area.unit_id, area = area.id }
                    } },
                    text = _"subscribe for update emails about this area"
                  }
                end }
              end }
            end }
          end }
        end
      
      else
        ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
          ui.tag{ content = _"I want to stay informed about this subject area" }
          ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
            ui.tag { tag = "li", content = function ()
              ui.tag { content = function ()
                ui.tag{ content = _"Edit your global " }
                ui.link {
                  module = "member", view = "settings_notification",
                  params = { return_to = "area", return_to_area_id = area.id },
                  text = _"notification settings"
                }
                ui.tag{ content = _" to receive updates by email" }
              end }
            end }
          end }
        end }
      end
      
      if app.session.member and app.session.member:has_voting_right_for_unit_id(area.unit_id) then

        if not config.disable_delegations then
          
          ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()

            if not area.delegation_info.first_trustee_id then
              ui.tag{ content = _"I want to delegate this subject area" }
            else
              ui.tag{ content = _"You delegated this subject area" }
            end

            ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
              if area.delegation_info.own_delegation_scope == "unit" then
                ui.tag { tag = "li", content = function ()
                  ui.link {
                    module = "delegation", view = "show", params = {
                      unit_id = area.unit_id,
                    },
                    content = _("change/revoke delegation of organizational unit")
                  }
                end }
              end
              
              if area.delegation_info.own_delegation_scope == nil then
                ui.tag { tag = "li", content = function ()
                  ui.link {
                    module = "delegation", view = "show", params = {
                      area_id = area.id
                    },
                    content = _"choose subject area delegatee" 
                  }
                end }
              elseif area.delegation_info.own_delegation_scope == "area" then
                ui.tag { tag = "li", content = function ()
                  ui.link {
                    module = "delegation", view = "show", params = {
                      area_id = area.id
                    },
                    content = _"change/revoke area delegation" 
                  }
                end }
              else
                ui.tag { tag = "li", content = function ()
                  ui.link {
                    module = "delegation", view = "show", params = {
                      area_id = area.id
                    },
                    content = _"change/revoke delegation only for this subject area" 
                  }
                end }
              end
            end }
          end }
        end 
        
        if app.session.member:has_initiative_right_for_unit_id ( area.unit_id ) then
          ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
            ui.tag{
              content = _("I want to start a new initiative", {
                area_name = area.name
              } ) 
            }
            ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
              ui.tag { tag = "li", content = _"Take a look through the existing issues. Maybe someone else started a debate on your topic (and you can join it) or the topic has been decided already in the past." }
              ui.tag { tag = "li", content = function ()
                ui.tag { content = function ()
                  ui.tag { content = _"If you cannot find any appropriate existing issue, " }
                  ui.link {
                    module = "draft", view = "new",
                    params = { area_id = area.id },
                    text = _"start an initiative in a new issue"
                  }
                end }
              end }
            end }
          end }
        end
      end
      if app.session.member:has_voting_right_for_unit_id ( area.unit_id ) then
        ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
          ui.tag{ content = _"I want to vote" }
          ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
            ui.tag { tag = "li", content = _"check the issues on the right, and click on 'Vote now' to vote on an issue which is in voting phase." }
          end }
        end }
      end
    else
      ui.container { attr = { class = "mdl-card__content mdl-card--border" }, content = function ()
        if not app.session.member_id then
          ui.tag{ content = _"Login to participate" }
          ui.tag{ tag = "ul", content = function()
            ui.tag{ tag = "li", content = function()
              ui.link{ module = "index", view = "login", content = _"Login" }
            end }
          end }
        else
          ui.tag{ content = _"You are not entitled to vote in this unit" }
        end
      end }
    end
  end }
  
end }
