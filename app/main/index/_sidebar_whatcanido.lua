ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
  ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
    ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"What can I do here?" }
  end }
  ui.container{ attr = { class = "what-can-i-do-here" }, content = function()

    if app.session.member then
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
        ui.tag{ content = _"I want to know whats going on" }
        ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
          ui.tag { tag = "li", content = _"take a look on the issues (see right)" }
          ui.tag { tag = "li", content = _"by default only those issues are shown, for which your are eligible to participate (change filters on top of the list)" }
        end } 
      end }
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
        ui.tag{ content = _"I want to stay informed" }
        ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
          ui.tag { tag = "li", content = function ()
            ui.tag{ content = _"check your " }
            ui.link{
              module = "member", view = "settings_notification",
              params = { return_to = "home" },
              text = _"notifications settings"
            }
          end }
          if not config.voting_only then
            ui.tag { tag = "li", content = function ()
              ui.tag{ content = _"subscribe subject areas or add your interested to issues and you will be notified about changes (follow the instruction on the area or issue page)" }
            end }
          end
        end } 
      end }
      if not config.voting_only and app.session.member.has_initiative_right then
        ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
          ui.tag{ content = _"I want to start a new initiative" }
          ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
            ui.tag { tag = "li", content = _"open the appropriate subject area for your issue and follow the instruction on that page." }
          end } 
        end }
      end
      if app.session.member.has_voting_right then
        ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
          ui.tag{ content = _"I want to vote" }
          ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
            ui.tag { tag = "li", content = _"check the issues on the right, and click on 'Vote now' to vote on an issue which is in voting phase." }
          end }
        end }
        if not config.disable_delegations then
          ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
            ui.tag{ content = _"I want to delegate my vote" }
            ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
              ui.tag { tag = "li", content = _"open the organizational unit, subject area or issue you like to delegate and follow the instruction on that page." }
            end } 
          end }
        end
      end
      if not config.single_unit_id and not config.do_not_show_other_units_link then
        ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
          ui.tag{ content = _"I want to take a look at other organizational units" }
          ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
            ui.tag { tag = "li", content = function ()
              ui.link{
                module = "unit", view = "list",
                text = _"show all units"
              }
            end }
          end } 
        end }
      end
      if config.download_dir then
        ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
          ui.tag{ content = _"I want to download all data" }
          ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
            ui.tag { tag = "li", content = function ()
              ui.link{
                module = "index", view = "download",
                text = _"download database"
              }
            end }
          end } 
        end }
      end
    end
    if not app.session.member then
      ui.container { attr = { class = "mdl-card__content mdl-card--border" }, content = function ()
        ui.tag{ content = _"Login to participate" }
        ui.tag{ tag = "ul", content = function()
          ui.tag{ tag = "li", content = function()
            ui.link{ module = "index", view = "login", content = _"Login [button]" }
          end }
        end }
      end }
    end
    if not config.voting_only then
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
        ui.tag{ content = _"I want to learn more about LiquidFeedback" }
        if config.quick_guide and config.quick_guide.links then
          ui.container{ content = config.quick_guide.links }
        else
          ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
            ui.tag { tag = "li", content = function()
              ui.link { module = "help", view = "introduction", content = _"structured discussion" }
            end }
            ui.tag { tag = "li", content = function()
              ui.link { module = "help", view = "introduction", content = _"4 phases of a decision" }
            end }
            if not config.disable_delegations then
              ui.tag { tag = "li", content = function()
                ui.link { module = "help", view = "introduction", content = _"vote delegation" }
              end }
            end
            ui.tag { tag = "li", content = function()
              ui.link { module = "help", view = "introduction", content = _"preference voting" }
            end }
          end } 
        end
      end }
    end
  end }
end }
