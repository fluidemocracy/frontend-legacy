function ui.map(geo_objects, input_element_id)
  local header = config.map.header
  if type(header) == "function" then
    header = header()
  end
  slot.put_into("html_head", header)
  ui.container{ attr = { id = "map" }, content = "" }
  config.map.func(
    "map", 
    config.map.default_viewport.lon, 
    config.map.default_viewport.lat, 
    config.map.default_viewport.zoom,
    geo_objects,
    input_element_id
  )
end
