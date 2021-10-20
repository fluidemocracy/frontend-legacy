execute.inner()

local for_meta_navigation = false
if config.meta_navigation_items_func and config.meta_navigation_html_func then
  for_meta_navigation =
    request.get_module() == "index" and (
      request.get_view() == "login"
      or request.get_view() == "register"
      or request.get_view() == "reset_password"
      or request.get_view() == "send_login"
    )
    or (request.get_module() == "registration")
    or (request.get_module() == "member" and request.get_view() == "show" and param.get_id() == app.session.member_id)
    or (request.get_module() == "member" and request.get_view() == "history" and param.get_id() == app.session.member_id)
    or (request.get_module() == "member" and (
      string.match(request.get_view(), "^settings")
      or string.match(request.get_view(), "^edit")
    ))
  local items = config.meta_navigation_items_func(app.session.member, for_meta_navigation and "login" or "LiquidFeedback")
  local meta_navigation = config.meta_navigation_html_func(items)
  slot.put_into("meta_navigation", meta_navigation)
  local meta_navigation_style = config.meta_navigation_style_func(items)
  slot.put_into("meta_navigation_style", meta_navigation_style)
  if config.meta_navigation_extra_style_func then
    local meta_navigation_extra_style = config.meta_navigation_extra_style_func(items)
    slot.put_into("meta_navigation_style", meta_navigation_extra_style)
  end
  local meta_navigation_script = config.meta_navigation_script_func(items)
  slot.put_into("script", meta_navigation_script)
end

if not config.meta_navigation_items_func or not config.meta_navigation_html_func then
  slot.select ( 'header_bar', function ()
    ui.tag{ tag = "header", attr = { class = "mdl-layout__header mdl-layout__header--seamed" }, content = function()
      ui.container{ attr = { class = "mdl-layout__header-row" }, content = function()
        ui.link{ module = "index", view = "index", attr = { class = "mdl-layout-title" }, content = function()
          if config.instance_name then
            ui.tag{ attr = { class = "mdl-layout--large-screen-only" }, content = config.instance_name .. " ♦" } 
            slot.put(" ")
          end
          ui.tag{ content = "LiquidFeedback" }
        end }
        ui.tag{ attr = { class = "mdl-layout-spacer" }, content = "" }
        if app.session:has_access ("anonymous") then
          ui.form { attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--expandable mdl-textfield--floating-label mdl-textfield--align-right" }, method = "get", module = "index", view = "search", content = function ()
            ui.tag{ tag = "label", attr = { class = "mdl-button mdl-js-button mdl-button--icon", ["for"] = "fixed-header-drawer-exp" }, content = function()
              ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "search" }
            end }
            ui.container{ attr = { class = "mdl-textfield__expandable-holder" }, content = function()
              ui.tag{ tag = "input", attr = { class = "mdl-textfield__input", type = "text", name = "q", id = "fixed-header-drawer-exp" }, content = "" }
            end }
          end }
        end
        
        if app.session.member == nil and not (
          request.get_module() == "index" and (request.get_view() == "login" or request.get_view() == "reset_password" or request.get_view() == "send_login")
        ) and not config.meta_navigation_html_func then
          local redirect_params = json.object()
          for key, val in pairs(request.get_param_strings()) do
            if type(val) == "string" then
              redirect_params[key] = val
            else
              -- shouldn't happen
              error("array type params not implemented")
            end
          end
          ui.tag{ tag = "nav", attr = { class = "mdl-navigation" }, content = function()
            local link = {
              content = function()
                ui.tag{ tag = "i", attr = { class = "material-icons", ["aria-hidden"] = "true", role="presentation" }, content = "exit_to_app" }
                slot.put(" ")
                ui.tag{ attr = { class = "mdl-layout--large-screen-only" }, content = function()
                  ui.tag{ content = _"Login [button]" }
                end }
              end,
              attr = { class = "mdl-navigation__link" }
            }
            if config.login and config.login.method == "oauth2" then
              link.module = "oauth2_client"
              link.view = "redirect"
              link.params = { provider = config.login.provider }
            else
              link.module = 'index'
              link.view   = 'login'
              link.params = {
                redirect_module = request.get_module(),
                redirect_view = request.get_view(),
                redirect_id = param.get_id(),
                redirect_params = redirect_params
              }
            end
            ui.link(link)
          end }
        end
          
        if app.session.member and not (
          config.meta_navigation_items_func and config.meta_navigation_html_func
        ) then
          ui.tag{ tag = "nav", attr = { class = "mdl-navigation" }, content = function()
            ui.tag{ tag = "span", module = "member", view = "show", id = app.session.member.id, attr = { id = "lf-member-menu", class = "mdl-navigation__link" }, content = function()
              ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "person" }
              ui.tag{ attr = { class = "mdl-layout--large-screen-only" }, content = function()
                ui.tag{ content = app.session.member.name }
              end }
            end }
          
            ui.tag { tag = "ul", attr = { class = "mdl-menu mdl-menu--bottom-right mdl-js-menu mdl-js-ripple-effect", ["for"] = "lf-member-menu" }, content = function()
              execute.view{ module = "member", view = "_menu", params = { item_class = "mdl-menu__item", link_class = "mdl-menu__link" } }
            end }
          end }

        end -- if app.session.member
      end }
    end }
  end)
end

if config.survey and request.get_module() ~= "survey" then
  execute.view{ module = "survey", view = "_notification" }
end

-- show notifications about things the user should take care of
--[[
if app.session.member then
  execute.view{
    module = "index", view = "_sidebar_notifications", params = {
      mode = "link"
    }
  }
end
--]]

slot.select ("footer", function ()
  ui.tag{ tag = "li", content = function()
    ui.link{ content = _"Quick guide", module = "help", view = "introduction" }
  end }
  if app.session.member_id and app.session.member.admin then
    if config.self_registration then
      ui.tag{ tag = "li", content = function()
        ui.link{ content = _"User management", module = "registration_admin", view = "index" }
      end }
    end
    ui.tag{ tag = "li", content = function()
      if config.admin_link then
        ui.link(config.admin_link)
      else
        ui.link{ content = _"System settings", module = "admin", view = "index" }
      end
    end }
  end
  ui.tag{ tag = "li", content = function()
    ui.link{
      text   = _"About site",
      module = 'index',
      view   = 'about'
    }
  end }
  if not config.extra_footer_func then
    if config.use_terms and app.session.member then
      ui.tag{ tag = "li", content = function()
        ui.link{
          text   = _"Use terms",
          module = 'index',
          view   = 'usage_terms'
        }
      end }
    end
  end
  if config.extra_footer_func then
    config.extra_footer_func()
  end
  ui.tag{ tag = "li", content = function()
    ui.link{
      text   = _"LiquidFeedback",
      external = "http://www.liquidfeedback.org/"
    }
  end }
end)

if not config.enable_debug_trace then
  trace.disable()
else
  slot.put_into('trace_button', '<div id="trace_show" onclick="document.getElementById(\'trace_content\').style.display=\'block\';this.style.display=\'none\';">TRACE</div>')
end



if app.current_initiative then
  app.current_issue = app.current_initiative.issue
end

if app.current_issue then
  app.current_area = app.current_issue.area
end

if app.current_area then
  app.current_unit = app.current_area.unit
end
