if not app.session:has_access("anonymous") then
  slot.put("<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Closed user group, please login.<br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br />")
  return
end

local unit_id = request.get_param{ name = "unit" }
local area_id = request.get_param{ name = "area" }

if unit_id == "all" then
  unit_id = nil
end

if area_id == "all" then
  area_id = nil
end

local unit
local area

if unit_id then
  unit = Unit:by_id(unit_id)
end

if area_id then
  area = Area:by_id(area_id)
end

ui.grid{ content = function()
  ui.cell_main{ content = function()

    execute.view{ module = "index", view = "_sidebar_motd_public" }
    
    execute.view{ module = "issue", view = "_list" }
  end }

  ui.cell_sidebar{ content = function()
    execute.view{ module = "index", view = "_sidebar_motd" }
    if app.session.member then
      execute.view{ module = "index", view = "_sidebar_notifications" }
    end
    if config.firstlife then
      ui.container{ attr = { class = "map mdl-special-card mdl-shadow--2dp pos-before-main" }, content = function()
        ui.tag{ tag = "iframe", attr = { src = config.firstlife.areaviewer_url .. "?" .. config.firstlife.coordinates .. "&domain=" .. request.get_absolute_baseurl(), class = "map" }, content = "" }
      end }
    end
    if config.map then
      local initiatives = Initiative:new_selector():exec()
      local geo_objects = {}
      for i, initiative in ipairs(initiatives) do
        if initiative.location and initiative.location.coordinates then
          local geo_object = {
            lon = initiative.location.coordinates[1],
            lat = initiative.location.coordinates[2],
            label = "i" .. initiative.id,
            description = slot.use_temporary(function()
              ui.link{ module = "initiative", view = "show", id = initiative.id, text = initiative.display_name }
            end),
            type = "initiative"
          }
          table.insert(geo_objects, geo_object)
        end
      end
      if ontomap_get_instances then
        local instances = ontomap_get_instances()
        for i, instance in ipairs(instances) do
          table.insert(geo_objects, instance)
        end
      end
      ui.container{ attr = { class = "map mdl-special-card mdl-shadow--2dp pos-before-main" }, content = function()
        ui.map(geo_objects)  
      end }
    end
    if config.logo then
      config.logo()
    end
    if area then
      execute.view{ module = "area", view = "_sidebar_whatcanido", params = { area = area } }
    elseif unit then
      execute.view{ module = "unit", view = "_sidebar_whatcanido", params = { unit = unit } }
    else
      execute.view{ module = "index", view = "_sidebar_whatcanido" }
    end
    
    execute.view { module = "index", view = "_sidebar_members" }
    
  end }
end }

