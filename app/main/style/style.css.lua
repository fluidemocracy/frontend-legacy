slot.set_layout(nil, "text/css")

local style = execute.chunk{ module = "style", chunk = "_style", params = { style = config.style } }

local scss = [[
@import "../style/mdl/color-definitions";
$color-primary: ]] .. style.color.primary .. [[;
$color-primary-dark: ]] .. style.color.primary .. [[;
$color-primary-contrast: ]] .. style.color.primary_contrast .. [[;
$color-accent: ]] .. style.color.accent .. [[;
$color-accent-contrast: ]] .. style.color.accent_contrast .. [[;
$checkbox-image-path: "]] .. request.get_absolute_baseurl() .. "static/mdl" .. [[";
@import "../style/mdl/material-design-lite"
]]

local key = extos.crypt(json.export(style.color), "$1$12345678") -- TODO hash function
local filename_scss = encode.file_path(WEBMCP_BASE_PATH, 'tmp', "style-" .. key .. ".scss")
local filename_css = encode.file_path(WEBMCP_BASE_PATH, 'tmp', "style-" .. key .. ".css")

local css_file = io.open(filename_css, "r")

if not config.css then
  config.css = {}
end

if not config.css[key] then
  if css_file then
    config.css[key] = css_file:read("*a")
  else
    local scss_file = assert(io.open(filename_scss, "w"))
    scss_file:write(scss)
    scss_file:write("\n")
    scss_file:close()

    local output, err, status = extos.pfilter(nil, "sassc", filename_scss)
    if status ~= 0 then
      error(err)
    end
    config.css[key] = output
    local css_file = assert(io.open(filename_css, "w"))
    css_file:write(config.css[key])
    css_file:close()
  end
end

slot.put_into("data", config.css[key])

