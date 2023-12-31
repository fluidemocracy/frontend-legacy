local id = param.get_id()

local hint = not id

local unit = Unit:by_id(id)

ui.titleAdmin(_"Organizational unit")

local units = {
  { id = nil, name = "" }
}

for i, unit in ipairs(Unit:get_flattened_tree()) do
  local name = ""
  for j = 2, unit.depth do
    name = name .. utf8.char(160).. utf8.char(160).. utf8.char(160).. utf8.char(160)
  end
  local name = name .. unit.name
  units[#units+1] = { id = unit.id, name = name }
end

ui.grid{ content = function()

  ui.cell_main{ content = function()
    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = unit and unit.name or _"New organizational unit" }
      end }
      ui.container{ attr = { class = "mdl-card__content" }, content = function()
        ui.form{
          attr = { class = "vertical section" },
          module = "admin",
          action = "unit_update",
          id = unit and unit.id,
          record = unit,
          routing = {
            default = {
              mode = "redirect",
              modules = "admin",
              view = "index"
            }
          },
          content = function()
            ui.sectionRow( function()
              ui.field.select{
                label = _"Parent unit",
                name = "parent_id",
                foreign_records = units,
                foreign_id      = "id",
                foreign_name    = "name"
              }
              ui.field.text{     label = _"Name",         name = "name" }
              ui.field.text{     label = _"Description",  name = "description", multiline = true }
              ui.field.text{     label = _"External reference",  name = "external_reference" }
              ui.field.text{     label = _"Attr",         name = "attr", value = unit and unit.attr or '{}' }
              ui.field.boolean{  label = _"Active?",      name = "active", value = hint and true or nil }

              slot.put("<br />")
              ui.submit{
                attr = { class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect" },
                text  = _"update unit" 
              }
              slot.put(" ")
              ui.link{ 
                attr = { class = "mdl-button mdl-js-button" },
                module = "admin", view = "index", content = _"cancel"
              }
            end )
          end
        }
      end }
    end }
  end }
end }
