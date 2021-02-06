local function field(name, label, value, tooltip)
  ui.field.text{
    container_attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label" },
    attr = { id = "field_" .. name, class = "mdl-textfield__input" },
    label_attr = { class = "mdl-textfield__label", ["for"] = "field_" .. name },
    label = label,
    name = name,
    value = value or nil
  }
  if tooltip then
    ui.container{ attr = { class = "mdl-tooltip", ["for"] = "field_" .. name }, content = tooltip }
  end
end

local function field_boolean(id, name, checked, label)
  ui.container{ content = function()
    ui.tag{ tag = "label", attr = {
        class = "mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect",
        ["for"] = id
      },
      content = function()
        ui.tag{
          tag = "input",
          attr = {
            id = id,
            class = "mdl-checkbox__input",
            type = "checkbox", name = name, value = "true",
            checked = checked and "checked" or nil,
          }
        }
        ui.tag{
          attr = { class = "mdl-checkbox__label", ['for'] = id },
          content = label
        } 
      end
    }
  end }
end

local id = param.get_id()

local member = Member:by_id(id)

local deactivated = member and member.locked and member.login == nil and member.authority_login == nil

ui.titleAdmin(_"Member")

local units_selector = Unit:new_selector()
  
if member then
  units_selector
    :left_join("privilege", nil, { "privilege.member_id = ? AND privilege.unit_id = unit.id", member.id })
    :add_field("privilege.voting_right", "voting_right")
    :add_order_by("unit.name")
end

local units = units_selector:exec()
  
ui.grid{ content = function()

  ui.cell_main{ content = function()
    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        local text = _"Member"
        if member then
          text = text .. " ID " .. member.id
        end
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = text }
      end }
      ui.container{ attr = { class = "mdl-card__content" }, content = function()
        ui.form{
          attr = { class = "vertical section" },
          module = "admin",
          action = "member_update",
          id = member and member.id,
          record = member,
          readonly = not app.session.member.admin,
          routing = {
            default = {
              mode = "redirect",
              modules = "admin",
              view = "index"
            }
          },
          content = function()

            ui.container{ content = function()
              field("identification", _"Identification")
              if member and member.activated then
                slot.put(" &nbsp; ")
                field("name", "Screen name")
              end
            end }
            ui.container{ content = function()
              field("notify_email", _"Notification email (confirmed)")
              slot.put(" &nbsp; ")
              field("notify_email_unconfirmed", _"Notification email (unconfirmed)")
            end }
--            field("", "")
            
            
            if member and member.activated and not deactivated then
              field("login", "Login name")
            end

            for i, unit in ipairs(units) do
              field_boolean("checkbox_unit_" .. unit.id, "unit_" .. unit.id, unit.voting_right, unit.name)
              
            end
            slot.put("<br />")

            if member then
              ui.field.text{  label = _"Activated",       name = "activated", readonly = true }
            end
              
            if not member or not member.activated then
              ui.field.boolean{  label = _"Send invite?",       name = "invite_member" }
            end
            
            if member then
              ui.field.boolean{ 
                label = _"Member inactive?", name = "deactivate",
                readonly = true, 
                value = member and member.active == false
              }
            end
            
            if member then
              ui.field.boolean{
                label = _"Lock member?", name = "locked",
              }
            end
            
            slot.put("<br />")
            ui.field.boolean{  label = _"Admin?", name = "admin" }
            slot.put("<br />")
            ui.submit{
              attr = { class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect" },
              text  = _"update member"
            }
            slot.put(" &nbsp; ")
            if member then
              ui.link { 
                attr = { class = "mdl-button mdl-js-button" },
                module = "admin", view = "member_deactivate", content = _"Deactivate member", id = member.id 
              }
              slot.put(" &nbsp; ")
            end
            ui.link {
                attr = { class = "mdl-button mdl-js-button" },
                module = "admin", view = "index", content = _"cancel"
            }

          end
        }
      end }
    end }
  end }
end }
