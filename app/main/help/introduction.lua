ui.title(_"Introduction")

ui.grid{ content = function()
  ui.cell_main{ content = function()

    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--has-fab mdl-card--border" }, content = function ()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 1, content = function()
          if config.quick_guide and config.quick_guide.title then
            slot.put(config.quick_guide.title)
          else
            ui.tag{ content = _"Quick guide" }
          end
        end }
      end }
      ui.container { attr = { class = "draft mdl-card__content mdl-card--border" }, content = function()
        if config.quick_guide and config.quick_guide.content then
          slot.put(config.quick_guide.content)
        else
          ui.heading{ level = 2, content = _"Initiatives and issues" }
          ui.tag{ tag = "p", content = _"[introduction] iniatives and issues" }
          ui.heading{ level = 2, content = _"Subject areas" }
          ui.tag{ tag = "p", content = _"[introduction] subject areas" }
          ui.heading{ level = 2, content = _"Organizational units" }
          ui.tag{ tag = "p", content = _"[introduction] organizational units" }
          ui.heading{ level = 2, content = _"Rules of procedure" }
          ui.tag{ tag = "p", content = _"[introduction] rules of procedure" }
          ui.heading{ level = 2, content = _"Admission phase" }
          ui.tag{ tag = "p", content = _"[introduction] phase 1 admission" }
          ui.heading{ level = 2, content = _"Discussion phase" }
          ui.tag{ tag = "p", content = _"[introduction] phase 2 discussion" }
          ui.heading{ level = 2, content = _"Verification phase" }
          ui.tag{ tag = "p", content = _"[introduction] phase 3 verification" }
          ui.heading{ level = 2, content = _"Voting phase" }
          ui.tag{ tag = "p", content = _"[introduction] phase 4 voting" }
          ui.heading{ level = 2, content = _"Vote delegation" }
          ui.tag{ tag = "p", content = _"[introduction] vote delegation" }
          ui.heading{ level = 2, content = _"Preference voting" }
          ui.tag{ tag = "p", content = _"[introduction] preference voting" }
        end
      end }
    end }
  end }
end }
      
