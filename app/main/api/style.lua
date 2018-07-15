slot.set_layout(nil, "application/json")


local r = json.object{
  color = json.object()
}

local style = execute.chunk{ module = "style", chunk = "_style", params = { style = config.style } }

if style.color_md then
  r.color.md = {}
  for k, v in pairs(style.color_md) do
    r.color.md[k] = v
  end
end

if style.color_rgb then
  r.color.rgb = {}
  for k, v in pairs(style.color_rgb) do
    r.color.rgb[k] = v
  end
end

slot.put_into("data", json.export(json.object{ result = r }))
