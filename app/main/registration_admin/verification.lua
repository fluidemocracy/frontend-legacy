local verification = Verification:by_id(param.get_id())
local data = verification.verification_data or verification.request_data

local identification = config.self_registration.identification_func(data)
local member
if verification.verified_member_id then
  member = Member:by_id(verification.verified_member_id)
  identification = member.identification
end

local group, title, view
if verification.verified_member_id then
  if member.deleted then
    group = _"Cancelled accounts"
    title = _"Cancelled account"
    view = "verification_cancelled"
  else
    group = _"Accredited users"
    title = member.identification
    view = "verification_accredited"
  end
elseif verification.denied then
  group = "Rejected requests"
  title = _"Rejected request"
  view = "verification_rejected"
else
  group = "Open requests"
  title = _"Open request"
  view = "verification_requests"
end


ui.title(function()
  ui.link { module = "registration_admin", view = "index", content = _"User management" }
  slot.put ( " » " )
  ui.link { module = "registration_admin", view = view, content = group }
  slot.put ( " » " )
  ui.tag { tag = "span", content = title }
end)
app.html_title.title = _"User management"

ui.container{ attr = { class = "mdl-grid" }, content = function()
  ui.container{ attr = { class = "mdl-cell mdl-cell--12-col" }, content = function()
    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = title }
      end }


      ui.form{
        module = "registration_admin", action = "update_verification", id = verification.id,
        routing = { ok = { mode = "redirect", module = "registration_admin", view = view } },
        record = data,
        content = function()

          if not verification.verified_member_id then
            ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
              ui.container{ content = verification.comment and verification.comment:gsub("///", " / ") or ""}
            end }
          end
      
          ui.container{ attr = { class = "mdl-card__content" }, content = function()

            for i, field in ipairs(config.self_registration.fields) do
              ui.container{ content = function()
                if field.type == "image" then
                  ui.link{ content = field.label, module = "registration_admin", view = "verification_image", id = verification.request_data[field.name], params = { field = i }, attr = { target = "_blank" } }
                elseif field.name == "unit" then
                  local units_selector = Unit:new_selector()
                    :add_where{ "active" }
                  if field.where then
                    units_selector:add_where(field.where)
                  end
                  local units = units_selector:exec()
                  if field.optional then
                    table.insert(units, {
                      id = "",
                      name = _"None"
                    })
                  end
                  ui.field.select{
                    label = field.label,
                    foreign_records = units,
                    foreign_id = "id",
                    foreign_name = "name",
                    name = field.name
                  }
                else
                  ui.field.text{
                    container_attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label" },
                    attr = { id = "lf-register__data_" .. field.name, class = "mdl-textfield__input" },
                    label_attr = { class = "mdl-textfield__label", ["for"] = "lf-register__data" .. field.name },
                    label = field.label,
                    name = field.name
                  }
                  ui.tag{ content = verification.request_data[field.name] }
                end
              end }
            end
            
            ui.field.text{
              container_attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label", style = "width: 30em;" },
              attr = { id = "lf-register__data_identification", class = "mdl-textfield__input" },
              label_attr = { class = "mdl-textfield__label", ["for"] = "lf-register__data_identification" },
              label = "Identification",
              name = "identification",
              value = identification
            }
            
          end }
            
          ui.container{ attr = { class = "mdl-card__actions mdl-card--border" }, content = function()
            
            if verification.denied then
              ui.link{ attr = { class = "mdl-button mdl-js-button mdl-button--raised" }, module = "registration_admin", view = view, content = "Back" }
            elseif verification.verified_member_id then
              ui.submit{ attr = { class = "mdl-button mdl-js-button mdl-button--raised" }, value = "Save personal data" }
              slot.put(" &nbsp; ")
              if not member.activated then
                ui.submit{ name = "invite", attr = { class = "mdl-button mdl-js-button mdl-button--raised" }, value = "Send email invitation again" }
                slot.put(" &nbsp; ")
              end
              ui.link{ attr = { class = "mdl-button mdl-js-button mdl-button--raised" }, module = "registration_admin", view = view, content = "Back" }
              slot.put(" &nbsp; ")
              ui.submit{ name = "cancel", attr = { class = "mdl-button mdl-js-button" }, value = _"Delete account" }
            else
              ui.submit{ name = "accredit", attr = { class = "mdl-button mdl-js-button mdl-button--raised" }, value = "Accredit user" }
              slot.put(" &nbsp; ")
              ui.submit{ attr = { class = "mdl-button mdl-js-button mdl-button--raised" }, value = "Save personal data" }
              slot.put(" &nbsp; ")
              ui.link{ attr = { class = "mdl-button mdl-js-button mdl-button--raised" }, module = "registration_admin", view = view, content = "Back" }
              slot.put(" &nbsp; ")
              ui.submit{ name = "drop", attr = { class = "mdl-button mdl-js-button" }, value = "Reject request" }
            end
          end }
      
        end 
      }
    end }
      
    local verifications = Verification:new_selector()
      :join("member", nil, "member.id = verification.verified_member_id")
      :add_where{ "member.identification = ?", identification }
      :add_where{ "verification.id <> ?", verification.id }
      :exec()
      
    if #verifications > 0 then
          
      ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
        ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
          ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = function()
            ui.tag{ content = _"Same identification" }
          end }
        end }
        ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
          execute.view{ module = "registration_admin", view = "_verification_list", params = { verifications = verifications } }
        end }
      end }
    end
    
    for i, field_name in ipairs(config.self_registration.match_fields) do
      local field
      for j, f in ipairs(config.self_registration.fields) do
        if f.name == field_name then
          field = f
        end
      end
      local verifications = Verification:new_selector()
        :add_where("verified_member_id NOTNULL")
        :add_where{ "lower(request_data->>'" .. field.name .. "') = lower(?)", data[field.name] }
        :add_where{ "verification.id <> ?", verification.id }
        :exec()
        
      if #verifications > 0 then
        ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
          ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
            ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = function()
              ui.tag{ content = _"Same " .. field.label }
            end }
          end }
          ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
            execute.view{ module = "registration_admin", view = "_verification_list", params = { verifications = verifications } }
          end }
        end }
      end
    end
    
  end }
end }

