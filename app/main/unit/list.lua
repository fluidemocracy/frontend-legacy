ui.title(_"Unit list")

ui.grid{ content = function()
  ui.cell_main{ content = function()

    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Unit list" }
      end }
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()

        execute.view{ module = "unit", view = "_list" }
      end }
    end }
  end }
end }



