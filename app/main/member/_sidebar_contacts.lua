local member = param.get("member", "table")

local public_contacts_selector = Contact:build_selector{
  public = true,
  member_id = member.id,
  order = "name"
}

local private_contacts_selector = Contact:build_selector{
  public = false,
  member_id = member.id,
  order = "name"
}

ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
  ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
    ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Published contacts" }
  end }

  ui.container { attr = { class = "mdl-card__content mdl-card--border" }, content = function()
    ui.container{ content = _"Published contacts" }
    if public_contacts_selector:count() == 0 then
      ui.container{ content = _"No published contacts" }
    else
      ui.paginate{
        selector = public_contacts_selector,
        name = "contacts",
        content = function()
          local contacts = public_contacts_selector:exec()
          for i, contact in ipairs(contacts) do
            ui.container{ content = function()
              execute.view{ module = "member_image", view = "_show", params = {
                member_id = contact.other_member.id, class = "micro_avatar", 
                popup_text = contact.other_member.name,
                image_type = "avatar", show_dummy = true,
              } }
              slot.put(" ")
              ui.link{
                content = contact.other_member.name,
                module = "member",
                view = "show",
                id = contact.other_member.id
              }
              if app.session.member_id == member.id then
                ui.link{
                  content = function() 
                    ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "get_app" }
                  end,
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
                ui.link{
                  content = function() 
                    ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "delete" }
                  end,
                  module = "contact",
                  action = "remove_member",
                  id = contact.other_member_id,
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
              end
            end }
          end
        end
      }
    end
  end }

  if member.id == app.session.member_id then
    ui.container { attr = { class = "mdl-card__content mdl-card--border" }, content = function()
      ui.tag{ content = _"Private contacts" }

      if app.session.member_id and app.session.member_id == member.id 
        and private_contacts_selector:count() > 0
      then

        ui.paginate{
          selector = private_contacts_selector,
          name = "contacts",
          content = function()
            local contacts = private_contacts_selector:exec()
            for i, contact in ipairs(contacts) do
              ui.container{ content = function()
                execute.view{ module = "member_image", view = "_show", params = {
                  member_id = contact.other_member.id, class = "micro_avatar", 
                  popup_text = contact.other_member.name,
                  image_type = "avatar", show_dummy = true,
                } }
                slot.put(" ")
                ui.link{
                  content = contact.other_member.name,
                  module = "member",
                  view = "show",
                  id = contact.other_member.id
                }
                slot.put(" ")
                ui.link{
                  content = function() 
                    ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "publish" }
                  end,
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
                ui.link{
                  content = function() 
                    ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "delete" }
                  end,
                  module = "contact",
                  action = "remove_member",
                  id = contact.other_member_id,
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
            end
          end
        }
      end
    end }
  end
end }
