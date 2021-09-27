if app.session.member and config.motd_intern_top then
  ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
    ui.container{ attr = { class = "mdl-card__content" }, content = function()
      ui.container{
        attr = { class = "draft motd" },
        content = function()
          slot.put(config.motd_intern_top)
        end
      }
    end }
  end }
end
