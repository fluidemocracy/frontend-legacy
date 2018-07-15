local issue = param.get("issue", "table")
local link_issue = param.get("link_issue", atom.boolean)

slot.put_into("header", issue.name)

ui.title ( function ()
  
  if not config.single_unit_id then
    ui.link {
      attr = { class = "unit" },
      content = function()
        ui.tag{ attr = { class = "name" }, content = issue.area.unit.name }
      end,
      module = "index", view = "index",
      params = { unit = issue.area.unit.id }
    }

    ui.tag { attr = { class = "spacer" }, content = function()
      slot.put ( " » " )
    end }
  end
  
  if not config.single_area_id then
    ui.tag { attr = { class = "area" }, content = function()
      -- area link
      ui.link {
        content = function()
          ui.tag{ attr = { class = "name" }, content = issue.area.name }
        end,
        module = "index", view = "index",
        params = { unit = issue.area.unit_id, area = issue.area.id }
      }
    end }
  
    ui.tag { attr = { class = "spacer" }, content = function()
      slot.put ( " » " )
    end }
  end
  
  if link_issue then
    ui.link {
      content = function()
        ui.tag { attr = { class = "issue" }, content = issue.name }
      end,
      module = "issue", view = "show", id = issue.id
    }
  else
    ui.tag { attr = { class = "issue" }, content = issue.name }
  end
  
end )

