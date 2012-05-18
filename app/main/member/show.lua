local member = Member:by_id(param.get_id())

if not member or not member.activated then
  error("access denied")
end

app.html_title.title = member.name
app.html_title.subtitle = _("Member")

slot.select("title", function()
  execute.view{
    module = "member_image",
    view = "_show",
    params = {
      member = member,
      image_type = "avatar"
    }
  }
end)

slot.put_into("title", encode.html(_"Member '#{member}'":gsub("#{member}", member.name)))

slot.select("actions", function()
  ui.link{
    content = function()
      slot.put(encode.html(_"Show member history"))
    end,
    module  = "member",
    view    = "history",
    id      = member.id
  }
  if not member.activated then
    ui.tag{
      tag = "div",
      attr = { class = "interest deactivated_member_info" },
      content = _"This member is deactivated."
    }
    slot.put(" ")
  end
  if not (member.id == app.session.member.id) then
    slot.put(" &middot; ")
    --TODO performance
    local contact = Contact:by_pk(app.session.member.id, member.id)
    if contact then
      ui.container{
        attr = { class = "interest" },
        content = _"You have saved this member as contact."
      }
      ui.link{
        text   = _"Remove from contacts",
        module = "contact",
        action = "remove_member",
        id     = contact.other_member_id,
        routing = {
          default = {
            mode = "redirect",
            module = request.get_module(),
            view = request.get_view(),
            id = param.get_id_cgi(),
            params = param.get_all_cgi()
          }
        }
      }
    elseif member.activated then
      ui.link{
        text    = _"Add to my contacts",
        module  = "contact",
        action  = "add_member",
        id      = member.id,
        routing = {
          default = {
            mode = "redirect",
            module = request.get_module(),
            view = request.get_view(),
            id = param.get_id_cgi(),
            params = param.get_all_cgi()
          }
        }
      }
    end
  end
  local ignored_member = IgnoredMember:by_pk(app.session.member.id, member.id)
  slot.put(" &middot; ")
  if ignored_member then
    ui.container{
      attr = { class = "interest" },
      content = _"You have ignored this member"
    }
    slot.put(" &middot; ")
    ui.link{
      text   = _"Stop ignoring member",
      module = "member",
      action = "update_ignore_member",
      id     = member.id,
      params = { delete = true },
      routing = {
        default = {
          mode = "redirect",
          module = request.get_module(),
          view = request.get_view(),
          id = param.get_id_cgi(),
          params = param.get_all_cgi()
        }
      }
    }
  elseif member.activated then
    ui.link{
      attr = { class = "interest" },
      text    = _"Ignore member",
      module  = "member",
      action  = "update_ignore_member",
      id      = member.id,
      routing = {
        default = {
          mode = "redirect",
          module = request.get_module(),
          view = request.get_view(),
          id = param.get_id_cgi(),
          params = param.get_all_cgi()
        }
      }
    }
  end
end)

util.help("member.show", _"Member page")

execute.view{
  module = "member",
  view = "_show",
  params = { member = member }
}

