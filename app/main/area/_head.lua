local area = param.get("area", "table")
local member = param.get("member", "table")

ui.title ( function ()

  -- unit link
  ui.link {
    attr = { class = "unit" },
    content = function()
      ui.tag{ attr = { class = "name" }, content = area.unit.name }
    end,
    module = "index", view = "index",
    unit = area.unit_id
  }

  ui.tag { attr = { class = "spacer" }, content = function()
    slot.put ( " » " )
  end }

  ui.tag { attr = { class = "area" }, content = function()
    -- area link
    ui.link {
      content = function()
        ui.tag{ attr = { class = "name" }, content = area.name }
      end,
      module = "index", view = "index",
      params = { unit = area.unit_id, area = area.id }
    }
    
    slot.put ( " " )

    execute.view {
      module = "delegation", view = "_info", params = { 
        area = area, member = member, for_title = true
      }
    }
  end }
  
end )
