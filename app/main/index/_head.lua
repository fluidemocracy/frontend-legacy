local unit_id = config.single_unit_id or request.get_param{ name = "unit" }
local area_id = config.single_area_id or request.get_param{ name = "area" }
if unit_id == "all" then
  unit_id = nil 
  area_id = nil
end
local unit
if unit_id then
  unit = Unit:by_id(unit_id)
end
if area_id == "all" then
  area_id = nil
end
local area
if area_id then
  area = Area:by_id(area_id)
end

if unit then
  ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
    ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
      ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = unit.name }
      if unit.description and #(unit.description) > 0 then
        ui.container{ attr = { class = "mdl-card__subtitle-text" }, content = unit.description }
      end
      if config.render_external_reference_unit then
        config.render_external_reference_unit(unit)
      end
    end }


    if not (config.voting_only and config.disable_delegations) and app.session.member_id then
      ui.container{ attr = { class = "mdl-card__actions" }, content = function()
          
        unit:load_delegation_info_once_for_member_id(app.session.member_id)
        
        local text
        if unit.delegation_info.own_delegation_scope == "unit" then
          local member = Member:by_id(unit.delegation_info.first_trustee_id)
          ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "forward" }
          execute.view{
            module = "member",
            view = "_show_thumb",
            params = {
              member = member
            }
          }
          text = _"change delegation..."
        else
          text = _"delegate..."
        end
        
        ui.link {
          attr = { class = "mdl-button mdl-js-button mdl-js-ripple-effect mdl-button--underlined" },
          module = "delegation", view = "show", params = {
            unit_id = unit.id,
          },
          content = text
        }

      end }
    end
  end }
end

if area then

  ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
    if unit then
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = area.name }
        if area.description and #(area.description) > 0 then
          ui.container{ attr = { class = "mdl-card__subtitle-text" }, content = area.description }
        end
      end }
    end
    if not (config.voting_only and config.disable_delegations) and app.session.member_id then
      ui.container{ attr = { class = "mdl-card__actions" }, content = function()
          
        area:load_delegation_info_once_for_member_id(app.session.member_id)

        local text
        if area.delegation_info.own_delegation_scope == "area" then
          local member = Member:by_id(area.delegation_info.first_trustee_id)
          ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "forward" }
          execute.view{
            module = "member",
            view = "_show_thumb",
            params = {
              member = member
            }
          }
          text = _"change delegation..."
        else
          text = _"delegate..."  
        end
        
        ui.link {
          attr = { class = "mdl-button mdl-js-button mdl-js-ripple-effect mdl-button--underlined" },
          module = "delegation", view = "show", params = {
            area_id = area.id,
          },
          content = text
        }
                        
        if not config.voting_only and app.session.member_id and app.session.member:has_initiative_right_for_unit_id ( area.unit_id ) then
          ui.link {
            attr = { class = "mdl-button mdl-js-button mdl-js-ripple-effect mdl-button--underlined" },
            module = "draft", view = "new",
            params = { area_id = area.id },
            content = function()
              ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "add" }
              ui.tag{ content = _"new issue" }
            end
          }
        end
      end }
    end
  end }
end


