if config.motd_public then
  ui.container{ attr = { class = "mdl-special-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
    ui.container{ attr = { class = "mdl-card__content" }, content = function()
      slot.put(config.motd_public)
    end }
  end }
end

if not app.session.member and config.motd_only_public then
  ui.container{ attr = { class = "mdl-special-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
    ui.container{ attr = { class = "mdl-card__content" }, content = function()
      slot.put(config.motd_only_public)
    end }
  end }
end
