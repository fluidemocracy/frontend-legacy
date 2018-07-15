local member = param.get("member", "table")

ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
  ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
    ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"What can I do here?" }
  end }
  ui.container{ attr = { class = "what-can-i-do-here" }, content = function()
  

    if not member.active then
      ui.container { attr = { class = "mdl-card__content mdl-card--border" }, content = function ()
        slot.put(" &middot; ")
        ui.tag{
          attr = { class = "interest deactivated_member_info" },
          content = _"This member is inactive"
        }
      end }   
    end
    
    if member.locked then
      ui.container { attr = { class = "mdl-card__content mdl-card--border" }, content = function ()
        slot.put(" &middot; ")
        ui.tag{
          attr = { class = "interest deactivated_member_info" },
          content = _"This member is locked"
        }
      end }   
    end

    if app.session.member_id == member.id then
      execute.view{ module = "member", view = "_settings_list" }
    end
  
    if app.session.member_id and not (member.id == app.session.member.id) then
      
      ui.container { attr = { class = "mdl-card__content mdl-card--border" }, content = function ()

        local contact = Contact:by_pk(app.session.member.id, member.id)
        if not contact then
          ui.tag{ content = _"I want to save this member as contact (i.e. to use as delegatee)" }
          ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
            ui.tag { tag = "li", content = function ()
              ui.link{
                text    = _"add to my list of public contacts",
                module  = "contact",
                action  = "add_member",
                id      = member.id,
                params = { public = true },
                routing = {
                  default = {
                    mode = "redirect",
                    module = request.get_module(),
                    view = request.get_view(),
                    id = request.get_id_string(),
                    params = request.get_param_strings()
                  }
                }
              }
            end }
            ui.tag { tag = "li", content = function ()
              ui.link{
                text    = _"add to my list of private contacts",
                module  = "contact",
                action  = "add_member",
                id      = member.id,
                routing = {
                  default = {
                    mode = "redirect",
                    module = request.get_module(),
                    view = request.get_view(),
                    id = request.get_id_string(),
                    params = request.get_param_strings()
                  }
                }
              }
            end }
          end }
        elseif contact.public then
          ui.tag{ content = _"You saved this member as contact (i.e. to use as delegatee) and others can see it" }
          ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
            ui.tag { tag = "li", content = function ()
              ui.link{
                text   = _"make this contact private",
                module = "contact",
                action = "add_member",
                id     = contact.other_member_id,
                params = { public = false },
                routing = {
                  default = {
                    mode = "redirect",
                    module = request.get_module(),
                    view = request.get_view(),
                    id = request.get_id_string(),
                    params = request.get_param_strings()
                  }
                }
              }
            end }
            ui.tag { tag = "li", content = function ()
              ui.link{
                text   = _"remove from my contact list",
                module = "contact",
                action = "remove_member",
                id     = contact.other_member_id,
                routing = {
                  default = {
                    mode = "redirect",
                    module = request.get_module(),
                    view = request.get_view(),
                    id = request.get_id_string(),
                    params = request.get_param_strings()
                  }
                }
              }
            end }
          end }
        else
          ui.tag{ content = _"You saved this member as contact (i.e. to use as delegatee)" }
          ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
            ui.tag { tag = "li", content = function ()
              ui.link{
                text   = _"make this contact public",
                module = "contact",
                action = "add_member",
                id     = contact.other_member_id,
                params = { public = true },
                routing = {
                  default = {
                    mode = "redirect",
                    module = request.get_module(),
                    view = request.get_view(),
                    id = request.get_id_string(),
                    params = request.get_param_strings()
                  }
                }
              }
            end }
            ui.tag { tag = "li", content = function ()
              ui.link{
                text   = _"remove from my contact list",
                module = "contact",
                action = "remove_member",
                id     = contact.other_member_id,
                routing = {
                  default = {
                    mode = "redirect",
                    module = request.get_module(),
                    view = request.get_view(),
                    id = request.get_id_string(),
                    params = request.get_param_strings()
                  }
                }
              }
            end }
          end }
        end
      end }
      
      ui.container { attr = { class = "mdl-card__content mdl-card--border" }, content = function ()
        local ignored_member = IgnoredMember:by_pk(app.session.member.id, member.id)
        if not ignored_member then
          ui.tag{ content = _"I do not like to hear from this member" }
          ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
            ui.tag { tag = "li", content = function ()
              ui.link{
                attr = { class = "interest" },
                text    = _"block this member",
                module  = "member",
                action  = "update_ignore_member",
                id      = member.id,
                routing = {
                  default = {
                    mode = "redirect",
                    module = request.get_module(),
                    view = request.get_view(),
                    id = request.get_id_string(),
                    params = request.get_param_strings()
                  }
                }
              }
            end }
          end }
        else
          ui.tag{ content = _"You blocked this member (i.e. you will not be notified about this members actions)" }
          ui.tag { tag = "ul", attr = { class = "ul" }, content = function ()
            ui.tag { tag = "li", content = function ()
              ui.link{
                text   = _"unblock member",
                module = "member",
                action = "update_ignore_member",
                id     = member.id,
                params = { delete = true },
                routing = {
                  default = {
                    mode = "redirect",
                    module = request.get_module(),
                    view = request.get_view(),
                    id = request.get_id_string(),
                    params = request.get_param_strings()
                  }
                }
              }
            end }
          end }
        end
      end }

    end
  end }
end }
