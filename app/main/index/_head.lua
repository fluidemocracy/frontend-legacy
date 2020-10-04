local unit_id = config.single_unit_id or tonumber(request.get_param{ name = "unit" })
if unit_id == "all" then
  unit_id = nil 
end
local unit
if unit_id then
  unit = Unit:by_id(unit_id)
end
local area_id = config.single_area_id or tonumber(request.get_param{ name = "area" })
if area_id == "all" then
  area_id = nil
end
local area
if area_id then
  area = Area:by_id(area_id)
end
if area and unit and area.unit_id ~= unit.id then
  area_id = nil
end
if area and area.unit_id == unit_id then
  if app.session.member_id then
    area:load_delegation_info_once_for_member_id(app.session.member_id)
  end

  ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
    if unit then
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        if not config.single_area_id then
          ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = unit.name .. " / " .. area.name }
        else
          ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = unit.name }
        end
      end }
    end
    if area.description and #(area.description) > 0 then
      if not config.single_area_id then
        ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = area.description }
      else
        ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = unit.description }
      end
    end
    if not (config.voting_only and config.disable_delegations) and app.session.member_id then
      ui.container{ attr = { class = "mdl-card__actions" }, content = function()
          
        if app.session.member_id then
          if area.delegation_info.first_trustee_id then
              local member = Member:by_id(area.delegation_info.first_trustee_id)
              ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "forward" }
              execute.view{
                module = "member_image",
                view = "_show",
                params = {
                  member = member,
                  image_type = "avatar",
                  show_dummy = true
                }
              }
          end

          if not config.disable_delegations then
            if area.delegation_info.own_delegation_scope == "unit" then
              ui.link {
                attr = { class = "mdl-button mdl-js-button mdl-js-ripple-effect mdl-button--underlined" },
                module = "delegation", view = "show", params = {
                  unit_id = area.unit_id,
                },
                content = _("change/revoke delegation of organizational unit")
              }
              slot.put(" &nbsp; ")
            end
            if area.delegation_info.own_delegation_scope == nil then
              local text
              if config.single_area_id then
                text = _"choose delegatee"  
              else
                text = _"choose subject area delegatee"  
              end
              ui.link {
                attr = { class = "mdl-button mdl-js-button mdl-js-ripple-effect mdl-button--underlined" },
                module = "delegation", view = "show", params = {
                  area_id = area.id
                },
                content = function()
                  ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "forward" }
                  ui.tag{ content = text }
                end
              }
              slot.put(" &nbsp; ")
            elseif area.delegation_info.own_delegation_scope == "area" then
              local text
              if config.single_area_id then
                text = _"change/revoke delegation" 
              else
                text = _"change/revoke area delegation" 
              end
              ui.link {
                attr = { class = "mdl-button mdl-js-button mdl-js-ripple-effect mdl-button--underlined" },
                module = "delegation", view = "show", params = {
                  area_id = area.id
                },
                content = text
              }
              slot.put(" &nbsp; ")
            else
              ui.link {
                attr = { class = "mdl-button mdl-js-button mdl-js-ripple-effect mdl-button--underlined" },
                module = "delegation", view = "show", params = {
                  area_id = area.id
                },
                content = _"change/revoke delegation only for this subject area" 
              }
              slot.put(" &nbsp; ")
            end
          end
        end
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
elseif unit then
  ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
    ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
      ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = unit.name }
    end }
    if unit.description and #(unit.description) > 0 then
      ui.container{ attr = { class = "mdl-card__supporting-text mdl-card--border" }, content = unit.description }
    end
    if config.render_external_reference_unit then
      config.render_external_reference_unit(unit)
    end
    --ui.container{ attr = { class = "mdl-card__actions mdl-card--border" }, content = function()
    --end }
  end }
else
  ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
    ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
      ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"All issues" }
    end }
    ui.container{ attr = { class = "mdl-card__supporting-text mdl-card--border" }, content = _"All issues in your units. Use filters above to limit results." }
  end }
end
  
