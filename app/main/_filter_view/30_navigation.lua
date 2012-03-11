slot.put_into("app_name", config.app_title)

slot.select('navigation', function()

  if config.public_access or app.session.member_id then
    ui.link{
      attr = { class = "logolf" },
      content = _"Home",
      module = 'index',
      view   = 'index'
    }
  end
  
  if app.session.member_id then
    ui.link{
      content = _"Units",
      module = 'unit',
      view   = 'list'
    }
    ui.link{
      content = _"Members",
      module = 'member',
      view   = 'list'
    }
    ui.link{
      content = _"Contacts",
      module = 'contact',
      view   = 'list'
    }
  end

  if config.public_access and app.session.member == nil then
    ui.link{
      text   = _"Login",
      module = 'index',
      view   = 'login',
      params = {
        redirect_module = request.get_module(),
        redirect_view = request.get_view(),
        redirect_id = param.get_id()
      }
    }
  end

  if app.session.member == nil then
    ui.link{
      text   = _"Registration",
      module = 'index',
      view   = 'register'
    }
    ui.link{
      text   = _"Reset password",
      module = 'index',
      view   = 'reset_password'
    }
  else 

    ui.container{ attr = { class = "member_info" }, content = function()
      ui.link{
        content = function()
          execute.view{
            module = "member_image",
            view = "_show",
            params = {
              member = app.session.member,
              image_type = "avatar",
              show_dummy = true,
              class = "micro_avatar",
            }
          }
          ui.tag{ content = app.session.member.name }
        end,
        module = "member",
        view = "show",
        id = app.session.member_id
      }

      ui.link{
        text   = _"Settings",
        module = "member",
        view = "settings"
      }

      if app.session.member_id then
        ui.link{
        --    image  = { static = "icons/16/stop.png" },
          text   = _"Logout",
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
      end
      
    end }

  end

end)

slot.select("footer", function()
  if app.session.member_id and app.session.member.admin then
    ui.link{
      text   = _"Admin",
      module = 'admin',
      view   = 'index'
    }
    slot.put(" &middot; ")
  end
  ui.link{
    text   = _"About site",
    module = 'index',
    view   = 'about'
  }
  slot.put(" &middot; ")
  ui.link{
    text   = _"Usage terms",
    module = 'index',
    view   = 'usage_terms'
  }
  slot.put(" &middot; ")
  ui.tag{ content = _"This site is using" }
  slot.put(" ")
  ui.link{
    text   = _"LiquidFeedback",
    external = "http://www.public-software-group.org/liquid_feedback"
  }
end)


if config.app_logo then
  slot.select("logo", function()
    ui.image{ static = config.app_logo }
  end)
end

execute.inner()
