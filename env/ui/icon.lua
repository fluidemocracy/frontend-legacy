function ui.icon(icon, class, id)
  class = class and "icon-" .. class .. " " or ""
  class = class .. "material-icons"
  ui.tag{ tag = "i", attr = { id = id, class = class }, content = icon }
end
