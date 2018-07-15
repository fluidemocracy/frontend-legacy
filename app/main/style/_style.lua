local style = param.get("style", "table")

local md_colors = {
  ["500"] = {
    red = "244,67,54",
    pink = "233,30,99",
    purple = "156,39,176",
    ["deep-purple"] = "103,58,183",
    indigo = "63,81,181",
    blue = "33,150,243",
    ["light-blue"] = "3,169,244",
    cyan = "0,188,212",
    teal = "0,150,136",
    green = "76,175,80",
    ["light-green"] = "139,195,74",
    lime = "205,220,57",
    yellow = "255,235,59",
    amber = "255,193,7",
    orange = "255,152,0",
    ["deep-orange"] = "255,87,34",
    brown = "121,85,72",
    grey = "158,158,158",
    ["blue-grey"] = "96,125,139",
  },
  ["A200"] = {
    red = "255,82,82",
    pink = "255,64,129",
    purple = "224,64,251",
    ["deep-purple"] = "124,77,255",
    indigo = "83,109,254",
    blue = "68,138,255",
    ["light-blue"] = "64,196,255",
    cyan = "24,255,255",
    teal = "100,255,218",
    green = "105,240,174",
    ["light-green"] = "178,255,89",
    lime = "238,255,65",
    yellow = "255,255,0",
    amber = "255,215,64",
    orange = "255,171,64",
    ["deep-orange"] = "255,110,64",
    brown ="62,39,35",
    grey = "33,33,33",
    ["blue-grey"] = "38,50,56"
  }
}

local r = {}

if style.color then
  r.color = {
    primary = style.color.primary,
    primary_dark = style.color.primary_dark,
    accent = style.color.accent,
    primary_contrast = style.color.primary_contrast,
    accent_contrast = style.color.accent_contrast 
  }
  r.color_rgb = {
    primary = style.color.primary,
    accent = style.color.accent
  }
elseif style.color_md then
  r.color_md = {
    primary = style.color_md.primary,
    primary_contrast = style.color_md.primary_contrast,
    accent = style.color_md.accent,
    accent_contrast = style.color_md.accent_contrast
  }
else
  r.color_md = {
    primary = "grey",
    primary_contrast = "dark",
    accent = "red",
    accent_contrast = "dark"
  }
end
if not r.color then
  r.color = {
    primary = "$palette-" .. r.color_md.primary .. "-500",
    primary_dark = "$palette-" .. r.color_md.primary .. "-700",
    accent = "$palette-" .. r.color_md.accent .. "-A200",
    primary_contrast = "$color-" .. r.color_md.primary_contrast.. "-contrast",
    accent_contrast = "$color-" .. r.color_md.accent_contrast .. "-contrast"
  }
  r.color_rgb = {
    primary = md_colors["500"][r.color_md.primary],
    accent = md_colors["A200"][r.color_md.accent]
  }
end

return r
