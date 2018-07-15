if true then return end

local member = param.get ( "member", "table" )
local units
if member then
  units = member:get_reference_selector("units"):add_order_by("name"):exec()
  units:load_delegation_info_once_for_member_id(member.id)
else
  units = Unit:new_selector():add_where("active"):add_order_by("name"):exec()
  ui.sidebar( "tab-whatcanido", function()
    ui.sidebarHead( function()
      ui.heading { level = 2, content = _"Organizational units" }
    end )
    ui.sidebarSection( function()
      execute.view { module = "unit", view = "_list" }
    end )
  end )
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


