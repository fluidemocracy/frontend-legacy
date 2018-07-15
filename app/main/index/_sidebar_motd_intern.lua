if config.motd_intern then
  ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
    ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
      ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Message of the day" }
    end }
    ui.container{ attr = { class = "mdl-card__content what-can-i-do-here" }, content = function()
      ui.container{
        attr = { class = "wiki motd" },
        content = function()
          slot.put(config.motd_intern)
        end
      }
    end }
  end }
end
