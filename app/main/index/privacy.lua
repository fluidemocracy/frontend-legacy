if not config.privacy_policy then
  return execute.view { module = "index", view = "404" }
end

ui.title(config.privacy_policy_headline or _"Privacy policy")

ui.grid{ content = function()
  ui.cell_main{ content = function()
    ui.container { attr = { class = "mdl-card mdl-shadow--2dp mdl-card__fullwidth" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = function()
           ui.tag{ content = config.privacy_policy_headline or _"Privacy policy" }
           if config.privacy_policy_subheadline then
            slot.put("<br>")
            ui.tag{ attr = { style = "font-size: 75%;" }, content = config.privacy_policy_subheadline }
          end
        end }
      end }
      ui.container{ attr = { class = "mdl-card__content draft" }, content = function()
        slot.put(config.privacy_policy)
      end }
    end }
  end }
end }
