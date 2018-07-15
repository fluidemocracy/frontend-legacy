request.set_status("404 Not found")

ui.title("404 Not found")

ui.grid{ content = function()
  
  ui.cell_main{ content = function()

    ui.container { attr = { class = "mdl-card mdl-shadow--2dp mdl-card__fullwidth" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Page not found" }
      end }
      ui.container{ attr = { class = "mdl-card__content" }, content = function()
        ui.link{
          content = _"Go back to home page",
          module = "index", view = "index"
        }
      end }
    end }
  end }
end }
