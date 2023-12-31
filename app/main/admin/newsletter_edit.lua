local id = param.get_id()

local newsletter = {}

if id then
  newsletter = Newsletter:by_id(id)
end

ui.titleAdmin(_"Newsletter")

ui.grid{ content = function()

  ui.cell_main{ content = function()
    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = newsletter and (newsletter.subject) or _"New newsletter" }
      end }
      ui.container{ attr = { class = "mdl-card__content" }, content = function()
        ui.form{
          attr = { class = "vertical section" },
          module = "admin",
          action = "newsletter_update",
          id = newsletter and newsletter.id,
          record = newsletter,
          routing = {
            default = {
              mode = "redirect",
              modules = "admin",
              view = "newsletter_list"
            }
          },
          content = function()

            local units = { 
              { id = 0, name = _"All members" },
              { id = "_", name = _"" },
            }
            for i, unit in ipairs(Unit:get_flattened_tree{include_hidden = true}) do
              units[#units+1] = unit
            end
            ui.field.text{ label = _"Date", name = "published" }
            ui.field.select{
              label = _"Recipient",
              name = "unit_id",
              foreign_records = units,
              foreign_id = "id",
              foreign_name = "name",
              disabled_records = { ["_"] = true },
              value = newsletter.unit_id
            }
            ui.field.boolean{  label = _"Override disable notifications?", name = "include_all_members" }
            slot.put("<br />")
            ui.field.text{     label = _"Subject", name = "subject" }
            ui.field.text{     label = _"Content", name = "content", multiline = true, attr = { rows = "20" } }

            ui.submit{  
              attr = { class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect" },
              text  = _"create newsletter" 
            }
            slot.put(" ")
            ui.link {
              attr = { class = "mdl-button mdl-js-button" },
              module = "admin", view = "index", content = _"cancel" 
            }

          end
        }
      end }
    end }
  end }
end }
