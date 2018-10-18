local show_not_in_use = param.get("show_not_in_use", atom.boolean) or false

local policies = Policy:build_selector{ active = not show_not_in_use }:exec()


ui.titleAdmin(_"Policy list")

ui.grid{ content = function()

  ui.cell_main{ content = function()
    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Policy list" }
      end }
      ui.container{ attr = { class = "mdl-card__content" }, content = function()

        if show_not_in_use then
          ui.link{
            text = _"Show policies in use",
            module = "admin",
            view = "policy_list"
          }

        else
          ui.link{
            text = _"Create new policy",
            module = "admin",
            view = "policy_show"
          }
          slot.put(" &middot; ")
          ui.link{
            text = _"Show policies not in use",
            module = "admin",
            view = "policy_list",
            params = { show_not_in_use = true }
          }

        end

        ui.list{
          records = policies,
          columns = {

            { content = function(record)
                ui.link{
                  text = record.name,
                  module = "admin",
                  view = "policy_show",
                  id = record.id
                }
              end
            }

          }
        }
      end }
    end }
  end }
end }
