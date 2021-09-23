local area = param.get("area", "table")

ui.title ( function ()

  if not app.single_unit_id then
    -- unit link
    ui.link {
      attr = { class = "unit" },
      content = function()
        ui.tag{ attr = { class = "name" }, content = area.unit.name }
      end,
      module = "index", view = "index",
      params = { unit = area.unit_id }
    }

    ui.tag { attr = { class = "spacer" }, content = function()
      slot.put ( " » " )
    end }
  end

  ui.tag{ content = area.name }
  
end )
