function util.micro_avatar(member, member_name)
  if type ( member ) == "number" then
    member = {
      id = member,
      name = member_name
    }
  end
  
  local function doit()
    if config.fastpath_url_func then
      ui.image{
        attr = {
          title = member.name,
          class = "mdl-chip__contact"
        },
        external = config.fastpath_url_func(member.id, "avatar")
      }
    else
      ui.image {
        attr = {
          title = member.name,
          class = "mdl-chip__contact"
        },
        module = "member_image",
        view = "show",
        extension = "jpg",
        id = member.id,
        params = {
          image_type = "avatar"
        }
      } 
    end
    ui.tag { attr = { class = "mdl-chip__text" }, content = member.name }
  end
  
  ui.tag {
    attr = { class = "microAvatar" },
    content = function ()
      if app.session:has_access("everything") then
        ui.link {
	  attr = { class = "mdl-chip mdl-chip--contact" },
          module = "member", view = "show", id = member.id,
          content = doit
        }
      else
        ui.tag{ 
	  attr = { class = "mdl-chip mdl-chip--contact" },
	  content = doit 
	}
      end
    end
  }
end
