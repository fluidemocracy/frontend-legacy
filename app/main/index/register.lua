local ldap_uid

if config.ldap.member and app.session.authority == "ldap" then
  ldap_uid = app.session.authority_uid
end

if config.registration_disabled and not ldap_uid then
  return execute.view { module = "index", view = "404" }
end

execute.view{ module = "index", view = "_lang_chooser" }

local step = param.get("step", atom.integer)
local code = param.get("code")
local notify_email = param.get("notify_email")
local name = param.get("name")
local login = param.get("login")

local member

if ldap_uid then
  member, err = ldap.create_member(ldap_uid, true)
  if err then
    error(err)
  end
elseif code then
  member = Member:new_selector()
    :add_where{ "invite_code = ?", code }
    :add_where{ "activated ISNULL" }
    :optional_object_mode()
    :exec()
end



ui.container{ attr = { class = "mdl-grid" }, content = function()
  ui.container{ attr = { class = "mdl-cell mdl-cell--12-col" }, content = function()
  ui.heading{ level = 1, content = _"Account registration" }
--[[
  if not code and not ldap_uid then
    ui.heading{ level = 1, content = _"Registration (step 1 of 3: Invite code)" }
  elseif (not member.notify_email and not notify_email)
         or (not member.name and not name)
         or (not member.login and not login and not member.authority)
         or step == 1 then
    ui.heading { level = 1, content = _"Registration (step 2 of 3: Personal information)" }
  else
    ui.heading { level = 1, content = _"Registration (step 3 of 3: Terms of use and password)" }
  end
--]]
  ui.sectionRow( function()
    ui.form{
      attr = { class = "wide" },
      module = 'index',
      action = 'register',
      params = {
        code = code,
        notify_email = notify_email,
        name = name,
        login = login,
        skip = param.get("skip"),
        redirect_module = param.get("redirect_module"),
        redirect_view = param.get("redirect_view"),
        redirect_id = param.get("redirect_id"),
        redirect_params = param.get("redirect_params")
      },
      content = function()

        if not code and not ldap_uid then
          ui.field.hidden{ name = "step", value = 1 }
          ui.tag { tag = "p", content = _"Please enter the invite code you've received" }
          ui.field.text{
            container_attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label" },
            attr = { id = "lf-register__code", class = "mdl-textfield__input" },
            label_attr = { class = "mdl-textfield__label", ["for"] = "lf-register__code" },
            label     = _'Invite code',
            name = 'code',
            value     = ''
          }
          slot.put("<br /><br />")
          ui.tag{
            tag = "input",
            attr = {
              type = "submit",
              class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored",
              value = _'proceed with registration'
            }
          }
          slot.put(" ")
        else
          if (not member.notify_email and not notify_email)
            or (not member.name and not name)
            or (not member.login and not login and not member.authority)
            or step == 1 then
            ui.field.hidden{ name = "step", value = 2 }

            ui.tag{
              tag = "p",
              content = _"This invite key is connected with the following information:"
            }
            
            execute.view{ module = "member", view = "_profile", params = { member = member, for_registration = true } }

            slot.put("<br /><br />")
            
            if not util.is_profile_field_locked(member, "notify_email") and not member.notify_email then
              ui.tag{
                tag = "p",
                content = _"Please enter your email address. This address will be used for automatic notifications (if you request them) and in case you've lost your password. This address will not be published. After registration you will receive an email with a confirmation link."
              }
              ui.field.text{
                container_attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label" },
                attr = { id = "lf-register__code", class = "mdl-textfield__input" },
                label_attr = { class = "mdl-textfield__label", ["for"] = "lf-register__code" },
                label     = _'Email address',
                name = 'notify_email',
                value     = param.get("notify_email") or member.notify_email
              }
            end
            if not util.is_profile_field_locked(member, "name") then
              ui.tag{
                tag = "p",
                content = _"Please choose a name, i.e. your real name or your nick name. This name will be shown to others to identify you."
              }
              ui.field.text{
                container_attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label" },
                attr = { id = "lf-register__code", class = "mdl-textfield__input" },
                label_attr = { class = "mdl-textfield__label", ["for"] = "lf-register__code" },
                label     = _'Screen name',
                name      = 'name',
                value     = param.get("name") or member.name
              }
            end
            if not util.is_profile_field_locked(member, "login") then
              ui.tag{
                tag = "p",
                content = _"Please choose a login name. This name will not be shown to others and is used only by you to login into the system. The login name is case sensitive."
              }
              ui.field.text{
                container_attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label" },
                attr = { id = "lf-register__code", class = "mdl-textfield__input" },
                label_attr = { class = "mdl-textfield__label", ["for"] = "lf-register__code" },
                label     = _'Login name',
                name      = 'login',
                value     = param.get("login") or member.login
              }
            end
            slot.put("<br /><br />")
            ui.tag{
              tag = "input",
              attr = {
                type = "submit",
                class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored",
                value = _'proceed with registration'
              }
            }
            if param.get("skip") ~= "1" then
              slot.put(" ")
              ui.link{
                attr = { class = "mdl-button mdl-js-button mdl-js-ripple-effect mdl-button--underlined" },
                content = _"one step back",
                module = "index",
                view = "register",
                params = {
                  invite = code,
                  redirect_module = param.get("redirect_module"),
                  redirect_view = param.get("redirect_view"),
                  redirect_id = param.get("redirect_id"),
                  redirect_params = param.get("redirect_params")
                }
              }
              end
            else
            ui.field.hidden{ name = "step", value = "3" }

            local need_to_accept_terms = false

            for i, checkbox in ipairs(config.use_terms_checkboxes) do
              local member_useterms = MemberUseterms:new_selector()
                :add_where{ "member_id = ?", member.id }
                :add_where{ "contract_identifier = ?", checkbox.name }
                :exec()
              if #member_useterms == 0 then
                need_to_accept_terms = true
              end
            end
            
            if need_to_accept_terms then
              ui.container{
                attr = { class = "wiki use_terms" },
                content = function()
                  slot.put(config.use_terms)
                end
              }

              for i, checkbox in ipairs(config.use_terms_checkboxes) do
                local member_useterms = MemberUseterms:new_selector()
                  :add_where{ "member_id = ?", member.id }
                  :add_where{ "contract_identifier = ?", checkbox.name }
                  :exec()
                if #member_useterms == 0 then
                  slot.put("<br />")
                  ui.tag{
                    tag = "div",
                    content = function()
                      ui.tag{
                        tag = "input",
                        attr = {
                          type = "checkbox",
                          id = "use_terms_checkbox_" .. checkbox.name,
                          name = "use_terms_checkbox_" .. checkbox.name,
                          value = "1",
                          style = "float: left;",
                          checked = param.get("use_terms_checkbox_" .. checkbox.name, atom.boolean) and "checked" or nil
                        }
                      }
                      slot.put("&nbsp;")
                      ui.tag{
                        tag = "label",
                        attr = { ['for'] = "use_terms_checkbox_" .. checkbox.name },
                        content = function() slot.put(checkbox.html) end
                      }
                    end
                  }
                end
              end

              slot.put("<br />")
            end
        
            member.notify_email = notify_email or member.notify_email
            member.name = name or member.name
            member.login = login or member.login
            
--            ui.heading { level = 2, content = _"Personal information" }
--            execute.view{ module = "member", view = "_profile", params = {
--              member = member, include_private_data = true
--            } }
--            ui.field.text{
--              readonly  = true,
--              label     = _'Login name',
--              name      = 'login',
--              value     = member.login
--            }
            
            if not (member.authority == "ldap") then
              ui.tag{
                tag = "p",
                content = _"Please choose a password and enter it twice. The password is case sensitive."
              }
              ui.field.password{
                container_attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label" },
                attr = { id = "lf-register__code", class = "mdl-textfield__input" },
                label_attr = { class = "mdl-textfield__label", ["for"] = "lf-register__code" },
                label     = _'Password',
                name      = 'password1',
              }
              slot.put("<br />")
              ui.field.password{
                container_attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label" },
                attr = { id = "lf-register__code", class = "mdl-textfield__input" },
                label_attr = { class = "mdl-textfield__label", ["for"] = "lf-register__code" },
                label     = _'Repeat password',
                name      = 'password2',
              }
            end
            
            slot.put("<br /><br />")
            ui.tag{
              tag = "input",
              attr = {
                type = "submit",
                class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored",
                value = _'activate account'
              }
            }
            slot.put(" ")
            ui.link{
              attr = { class = "mdl-button mdl-js-button mdl-js-ripple-effect mdl-button--underlined" },
              content = _"one step back",
              module = "index",
              view = "register",
              params = {
                code = code,
                notify_email = notify_email,
                name = name,
                login = login,
                skip = param.get("skip"),
                step = 1,
                redirect_module = param.get("redirect_module"),
                redirect_view = param.get("redirect_view"),
                redirect_id = param.get("redirect_id"),
                redirect_params = param.get("redirect_params")
              }
            }
          end
        end
      end
    }

    slot.put("<br /><br />")

    ui.link{
      attr = { class = "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect" },
      content = _"cancel",
      module = "index",
      action = "cancel_register",
      routing = { default = {
        mode = "redirect", module = "index", view = "login", params = {
          redirect_module = param.get("redirect_module"),
          redirect_view = param.get("redirect_view"),
          redirect_id = param.get("redirect_id"),
          redirect_params = param.get("redirect_params")
        }
      } }
    }
  end )
  end }
end }

