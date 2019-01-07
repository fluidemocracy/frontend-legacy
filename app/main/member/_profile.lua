local member = param.get("member", "table")

local for_registration = param.get("for_registration", atom.boolean)

ui.form{
  attr = { class = "form" },
  record = member,
  readonly = true,
  content = function()

    if not for_registration and MemberImage:by_pk(member.id, "photo", true) then
      ui.container { attr = { class = "member_photo" }, content = function()
        execute.view{
          module = "member_image",
          view = "_show",
          params = {
            member = member,
            image_type = "photo",
            force_update = app.session.member_id == member.id
          }
        }
      end }
    end
    
    if member.identification then
      ui.field.text{    label = _"Identification", name = "identification" }
    end
    if member.name then
      ui.field.text{ label = _"Screen name", name = "name" }
    end
    if for_registration and member.login then
      ui.field.text{    label = _"Login name", name = "login" }
    end
    
    if for_registration and member.notify_email then
      ui.field.text{    label = _"Notification email", name = "notify_email" }
    end
    if member.profile then
      local profile = member.profile.profile or {}
      if config.member_profile_fields then
        for i, field in ipairs(config.member_profile_fields) do
          if profile[field.id] and #(profile[field.id]) > 0 then
            ui.field.text{ label = field.name, name = field.id, value = profile[field.id] }
          end
        end
      end
    end

    if member.admin then
      ui.field.boolean{ label = _"Admin?",       name = "admin" }
    end
    if member.locked then
      ui.field.boolean{ label = _"Locked?",      name = "locked" }
    end
    if member.last_activity then
      ui.field.text{ label = _"Last activity (updated daily)", value = format.date(member.last_activity) or _"not yet" }
    end
    if member.profile and member.profile.statement and #member.profile.statement > 0 then
      slot.put("<br />")
      slot.put("<br />")
      ui.container{
        attr = { class = " wiki" },
        content = function()
          slot.put(member.profile:get_content("html"))
        end
      }
    end
  end
}

