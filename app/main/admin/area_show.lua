local id = param.get_id()

local hint = not id

local area = Area:by_id(id) or Area:new()

if not area.unit_id then
  area.unit_id = param.get("unit_id", atom.integer)
end

ui.titleAdmin(_"area")

ui.grid{ content = function()

  ui.cell_main{ content = function()
    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = area.name or _"New area" }
      end }
      ui.container{ attr = { class = "mdl-card__content" }, content = function()
        ui.form{
          attr = { class = "vertical section" },
          record = area,
          module = "admin",
          action = "area_update",
          routing = {
            ok = {
              mode = "redirect",
              module = "admin",
              view = "index",
              params = { unit_id = area.unit_id }
            },
          },
          id = id,
          content = function()
            local policies = Policy:build_selector{ active = true }:exec()
            local def_policy = {
              {
                id = "-1",
                name = _"No default"
              }
            }
            for i, record in ipairs(policies) do
              def_policy[#def_policy+1] = record
            end

            
            ui.section( function()
              ui.sectionRow( function()
                
                ui.field.hidden{ name = "unit_id", value = area.unit_id }
                ui.field.text{    label = _"Unit", value = area.unit.name, readonly = true }
                ui.field.text{    label = _"Name",        name = "name" }
                ui.field.text{    label = _"Description", name = "description", multiline = true }
                ui.field.text{    label = _"External reference", name = "external_reference" }
                ui.field.select{  label = _"Default Policy",   name = "default_policy",
                            value=area.default_policy and area.default_policy.id or "-1",
                            foreign_records = def_policy,
                            foreign_id      = "id",
                            foreign_name    = "name"
                }
                ui.container{ content = _"Allowed policies" }
                ui.multiselect{   name = "allowed_policies[]",
                                  foreign_records = policies,
                                  foreign_id      = "id",
                                  foreign_name    = "name",
                                  connecting_records = area.allowed_policies or {},
                                  foreign_reference  = "id",
                }
                slot.put("<br />")
                ui.field.text{    label = _"Admission quorum standard", name = "quorum_standard", value = hint and 0 or nil }
                ui.field.text{    label = _"Admission quorum issues", name = "quorum_issues", value = hint and 1 or nil }
                ui.field.text{    label = _"Admission quorum time", name = "quorum_time", value = hint and "1 days" or nil }
                ui.field.text{    label = _"Admission quorum exponent", name = "quorum_exponent", value = hint and 0.5 or nil }
                ui.field.text{    label = _"Admission qourum factor", name = "quorum_factor", value = hint and 2 or nil }
                slot.put("<br />")
                ui.field.boolean{ label = _"Active?",     name = "active", value = hint and true or nil }
                slot.put("<br />")
                ui.submit{
                  attr = { class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect" },
                  text = _"update area"
                }
                slot.put(" ")
                ui.link{
                  attr = { class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect" },
                  module = "admin", view = "index", content = _"cancel"
                }
              end )
            end )
          end
        }
      end }
    end }
  end }
end }
