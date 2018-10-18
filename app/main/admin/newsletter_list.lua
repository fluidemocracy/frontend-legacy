local newsletter = Newsletter:new_selector()
  :add_order_by("published DESC")
  :exec()

ui.titleAdmin(_"Newsletter")

ui.grid{ content = function()

  ui.cell_main{ content = function()
    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Newsletter list" }
      end }
      ui.container{ attr = { class = "mdl-card__content" }, content = function()

        ui.list{
          records = newsletter,
          columns = {
            { label = _"Unit", content = function(r) ui.tag{ content = r.unit and r.unit.name or _"All members" } end },
            { name = "published", label = _"Published" },
            { name = "subject", label = _"Subject" },
            { label = _"sent", content = function(r) 
              if not r.sent then 
                ui.link{ text = _"Edit", module = "admin", view = "newsletter_edit", id = r.id } 
              else
                ui.tag{ content = format.timestamp(r.sent) }
              end 
            end }
          }
        }
      end }
    end }
  end }
end }
