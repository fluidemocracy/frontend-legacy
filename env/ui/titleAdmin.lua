function ui.titleAdmin(title)
  ui.title(function()
    if title then
      ui.link { module = "admin", view = "index", content = _"System settings" }
    else
      ui.tag{ content = _"System settings" }
    end
    if title then
      slot.put ( " » " )
      ui.tag { tag = "span", content = title }
    end
  end)
end
