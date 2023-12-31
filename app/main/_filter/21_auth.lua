local module = request.get_module()
local view   = request.get_view()
local action = request.get_action()

local auth_needed = true

if module == 'index' and (
     view   == "login"
  or action == "login"
  or view   == "register"
  or action == "register"
  or action == "cancel_register"
  or view   == "about"
  or view   == "reset_password"
  or action == "reset_password"
  or view   == "send_login"
  or action == "send_login"
  or view   == "confirm_notify_email"
  or action == "confirm_notify_email"
  or view   == "menu"
  or action == "set_lang"
  or view   == "403"
  or view   == "404"
  or view   == "405"
  or view == "usage_terms" and config.use_terms_public_access == true
  or view == "privacy" and config.privacy_policy_public_access == true
) then
  auth_needed = false
end

if module == "registration" then
  auth_needed = false
end

if module == "style" then
  auth_needed = false
end

if module == "help" then
  auth_needed = false
end

if module == "oauth2" and (
     view   == "validate"
  or view   == "token"
  or view   == "session"
  or view   == "register"
) then
  auth_needed = false
end

if module == "oauth2_client" then
  auth_needed = false
end

if module == "api" then
  auth_needed = false
end

if app.session:has_access("anonymous") then

  if
    module == "index" and view == "index"
    or module == "area" and view == "show"
    or module == "unit" and view == "show"
    or module == "issue" and view == "show"
    or module == "issue" and view == "history"
    or module == "initiative" and view == "show"
    or module == "initiative" and view == "history"
    or module == "suggestion" and view == "show"
    or module == "draft" and view == "diff"
    or module == "draft" and view == "show"
    or module == "file" and view == "show.jpg"
    or module == "index" and view == "search"
    or module == "index" and view == "usage_terms"
    or module == "index" and view == "privacy"
    or module == "help" and view == "introduction"
    or module == "style"
  then
    auth_needed = false
  end

end

if app.session:has_access("authors_pseudonymous") then
  if module == "member_image" and view == "show" and param.get("image_type") == "avatar" then
    auth_needed = false
  end
end

if app.session:has_access("everything") then
  if module == "member_image" and view == "show" then
    auth_needed = false
  end
end

if app.session:has_access("all_pseudonymous") then
  if module == "vote" and view == "show_incoming"
   or module == "member" and view == "list"
   or module == "interest" and view == "show_incoming"
   or module == "vote" and view == "list" then
    auth_needed = false
  end
end

if app.session:has_access("everything") then
  if module == "member" and (view == "show" or view == "history") then
    auth_needed = false
  end
end

if module == "sitemap" then
  auth_needed = false
end

if app.session:has_access("anonymous") and not app.session.member_id and auth_needed and module == "index" and view == "index" then
  if app.single_unit_id then
    request.redirect{ module = "unit", view = "show", id = app.single_unit_id }
  else
    request.redirect{ module = "unit", view = "list" }
  end
  return
end

-- if not app.session.user_id then
--   trace.debug("DEBUG: AUTHENTICATION BYPASS ENABLED")
--   app.session.user_id = 1
-- end

if auth_needed and app.session.member == nil then
  trace.debug("Not authenticated yet.")
  local params = json.object()
  for key, val in pairs(request.get_param_strings()) do
    if type(val) == "string" then
      params[key] = val
    else
      -- shouldn't happen
      error("array type params not implemented")
    end
  end
  if config.login and config.login.method == "oauth2" then
    request.redirect{
      module = "oauth2_client",
      view = "redirect",
      params = { provider = config.login.provider }
    }
  else
    request.redirect{
      module = 'index', view = 'login', params = {
        redirect_module = module,
        redirect_view = view,
        redirect_id = param.get_id(),
        redirect_params = params
      }
    }
  end
elseif auth_needed and app.session.member.locked then
  trace.debug("Member locked.")
  request.redirect{ module = 'index', view = 'login' }
else
  if config.check_delegations_interval_hard and app.session.member_id and app.session.needs_delegation_check 
    and not (module == "admin" or (module == "index" and (
      view == "check_delegations" 
      or action == "check_delegations" 
      or action == "logout"
      or view == "about"
      or view == "usage_terms"
      or action == "set_lang")
    ))
    and not (module == "member_image" and view == "show") then
    request.redirect{ module = 'index', view = 'check_delegations' }
    return
  end
  if auth_needed then
    trace.debug("Authentication accepted.")
  else
    trace.debug("No authentication needed.")
  end

  --db:query("SELECT check_everything()")

  execute.inner()
  trace.debug("End of authentication filter.")
end

