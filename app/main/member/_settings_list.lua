

ui.container { attr = { class = "mdl-card__content mdl-card--border" }, content = function ()
  ui.container{ content = _"I want to show or edit my profile" }
  ui.tag { tag = "ul", content = function()

    ui.tag{ tag = "li", content = function()
      ui.link{
        content = _"show my profile",
        module  = "member",
        view    = "show",
        id = app.session.member_id
      }
    end }
    ui.tag{ tag = "li", content = function()
      ui.link{
        content = _"edit my profile",
        module  = "member",
        view    = "edit",
        id = app.session.member_id
      }
    end }
    
  end }

end }

ui.container { attr = { class = "mdl-card__content mdl-card--border" }, content = function ()

  ui.container{ content = _"I want to change account settings" }

  ui.tag { tag = "ul", content = function()

    if not util.is_profile_field_locked(app.session.member, "login") and not app.session.member.role then
      ui.tag{ tag = "li", content = function()
        ui.link{
          content = _"change my login",
          module  = "member",
          view    = "settings_login",
        }
      end }
    end

    if not util.is_profile_field_locked(app.session.member, "password") and not app.session.member.role then
      ui.tag{ tag = "li", content = function()
        ui.link{
          content = _"change my password",
          module  = "member",
          view    = "settings_password",
        }
      end }
    end

    if not util.is_profile_field_locked(app.session.member, "name") then
      ui.tag{ tag = "li", content = function()
        ui.link{
          content = _"change my screen name",
          module  = "member",
          view    = "settings_name"
        }
      end }
    end

    ui.tag{ tag = "li", content = function()
      ui.link{
        content = _"change avatar/photo",
        module  = "member",
        view    = "edit_images",
      }
    end }
    
    ui.tag{ tag = "li", content = function()
      ui.link{
        content = _"notification settings",
        module  = "member",
        view    = "settings_notification",
      }
    end }
    if not util.is_profile_field_locked(app.session.member, "notify_email") then
      ui.tag{ tag = "li", content = function()
        ui.link{
          content = _"notification email address",
          module  = "member",
          view    = "settings_email",
        }
      end }
    end
    
    if app.session.member.role then
      ui.tag{ tag = "li", content = function()
        ui.link{
          content = _"agents",
          module  = "member",
          view    = "settings_agent",
        }
      end }
    end
    
    if config.role_registration and not app.session.member.role then
      ui.tag{ tag = "li", content = function()
        ui.link{
          content = _"request role account",
          module  = "role",
          view    = "request",
        }
      end }
    end
    
    if config.oauth2 then
      ui.tag{ tag = "li", content = function()
        ui.link{
          content = _"connected applications",
          module  = "member",
          view    = "settings_applications",
        }
      end }
    end
    
    if config.download_dir then
      ui.tag{ tag = "li", content = function()
        ui.link{
          content = _"database download",
          module  = "index",
          view    = "download",
        }
      end }
    end

  end }

end }

ui.container { attr = { class = "mdl-card__content mdl-card--border" }, content = function ()

  ui.container{ content = _"Logout" }

  ui.tag { tag = "ul", content = function()
    ui.tag{ tag = "li", content = function()
      ui.link{
        text   = _"logout",
        module = 'index',
        action = 'logout',
        routing = {
          default = {
            mode = "redirect",
            module = "index",
            view = "index"
          }
        }
      }
    end }

  end }
  
end }
