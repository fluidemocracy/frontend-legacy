local member = app.session.member
local units
if member then
  units = member:get_reference_selector("units"):add_order_by("name"):exec()
  units:load_delegation_info_once_for_member_id(member.id)
else
  units = Unit:new_selector():add_where("active"):add_order_by("name"):exec()
end

slot.select("drawer", function()
  ui.container{ attr = { class = "mdl-layout__drawer" }, content = function()
    ui.tag{ tag = "nav", attr = { class = "mdl-navigation" }, content = function ()
      ui.link{ content = config.instance_name, attr = { class = "mdl-navigation__link mdl-menu__item--full-bleed-divider mdl-navigation__head" }, module = "index", view = "index" }

      if #units > 0 then
        for i, unit in ipairs(units) do
          local class = "mdl-navigation__link mdl-navigation__head" 
          if i == #units then
            class = class .. " mdl-menu__item--full-bleed-divider"
          end
          ui.link{ attr = { class = class }, content = unit.name, module = "unit", view = "show", id = unit.id }
          local areas = unit.areas
          for i, area in ipairs(areas) do
            local class = "mdl-navigation__link mdl-menu__item--small" 
            if i == #areas then
              class = class .. " mdl-menu__item--full-bleed-divider"
            end
            ui.link{ attr = { class = class }, module = "area", view = "show", id = area.id, content = function()
              ui.tag{ content = "⤷" }
              slot.put(" ")
              ui.tag{ content = area.name }
            end }
          end
        end
      end

      ui.link{ attr = { class = "mdl-navigation__link mdl-menu__item--full-bleed-divider" }, content = _"Member list", module = "member", view = "list" }
      ui.link{ attr = { class = "mdl-navigation__link" }, content = _"Quick guide", module = "help", view = "introduction" }

      if app.session.member_id and app.session.member.admin then
        ui.link{ attr = { class = "mdl-navigation__link mdl-menu__item--full-bleed-divider" }, content = _"System settings", module = "admin", view = "index" }
      end
      
    end }
  end }
end)

if true then
  return
end

for i, unit in ipairs(units) do

  ui.sidebar ( "tab-whatcanido units", function ()

    local areas_selector = Area:new_selector()
      :reset_fields()
      :add_field("area.id", nil, { "grouped" })
      :add_field("area.unit_id", nil, { "grouped" })
      :add_field("area.name", nil, { "grouped" })
      :add_where{ "area.unit_id = ?", unit.id }
      :add_where{ "area.active" }
      :add_order_by("area.name")

    local areas = areas_selector:exec()
    if member then
      areas:load_delegation_info_once_for_member_id(member.id)
    end
    
    if #areas > 0 then

      ui.container {
        attr = { class = "sidebarHead" },
        content = function ()
          ui.heading { level = 2, content = function ()
            ui.link {
              attr = { class = "unit" },
              module = "unit", view = "show", id = unit.id,
              content = unit.name
            }
          
            if member then
              local delegation = Delegation:by_pk(member.id, unit.id, nil, nil)
              
              if delegation then
                ui.link { 
                  module = "delegation", view = "show", params = {
                    unit_id = unit.id
                  },
                  attr = { class = "delegation_info" }, 
                  content = function ()
                    ui.delegation(delegation.trustee_id, delegation.trustee.name)
                  end
                }
              end
            end
          end }
          
        end
      }
      
      
      ui.tag { tag = "div", attr = { class = "areas areas-" .. unit.id }, content = function ()
      
        for i, area in ipairs(areas) do

          ui.tag { tag = "div", attr = { class = "sidebarRow" }, content = function ()
            
            if member then
              local delegation = Delegation:by_pk(member.id, nil, area.id, nil)
        
              if delegation then
                ui.link { 
                  module = "delegation", view = "show", params = {
                    area_id = area.id
                  },
                  attr = { class = "delegation_info" }, 
                  content = function ()
                    ui.delegation(delegation.trustee_id, delegation.trustee_id and delegation.trustee.name)
                  end
                }
              end
            end
      
            slot.put ( " " )
            
            ui.link {
              attr = { class = "area" },
              module = "area", view = "show", id = area.id,
              content = area.name
            }
            
            
          end }
        end
      end }
    end 
  end )
end


