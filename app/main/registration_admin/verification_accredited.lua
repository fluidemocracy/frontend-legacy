local mode = param.get("mode")

ui.title(function()
  ui.link { module = "registration_admin", view = "index", content = _"User management" }
  slot.put ( " » " )
  ui.tag { tag = "span", content = "Accredited users"}
end)
app.html_title.title = _"User management"

ui.container{ attr = { class = "mdl-grid" }, content = function()
  ui.container{ attr = { class = "mdl-cell mdl-cell--12-col" }, content = function()

    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = function()
          ui.tag{ content = _"Accredited users" }
        end }
      end }

      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()

        local verifications_selector = Verification:new_selector()
          :join("member", nil, "member.id = verification.verified_member_id")
          :add_where("member.deleted ISNULL")
          
        if mode == "activated" then
          verifications_selector:add_where("member.activated NOTNULL")
        end
        
        if mode ~= "not_activated" then
          verifications_selector:add_order_by("member.identification")
          local verifications = verifications_selector:exec()
          
          if #verifications > 0 then
            ui.list{
              records = verifications,
              columns = {
                { 
                  label = _"Name",
                  content = function(record)
                    ui.container{ content = function()
                      local member = Member:by_id(record.verified_member_id)
                      if member then
                        ui.link{ module = "registration_admin", view = "verification", id = record.id, content = member.identification or "[no ident]" }  
                      end
                    end }
                  end
                },
                --[[
                { 
                  label = _"City",
                  content = function(record)
                    ui.container{ content = (record.verification_data or record.request_data).zip_code }
                    ui.tag{ content = " " }
                    ui.tag{ content = (record.verification_data or record.request_data).city }
                  end
                },
                --]]
                { 
                  label = _"Account",
                  content = function(record)
                    local member = Member:by_id(record.verified_member_id)
                    if member and member.activated then
                      ui.link{ module = "member", view = "show", id = record.verified_member_id, content = "ID " .. record.verified_member_id }
                    else
                      ui.tag{ content = "ID " }
                      ui.tag{ content = record.verified_member_id }
                      ui.tag{ content = ", " }
                      ui.tag{ content = _"not activated (yet)" }
                      
                    end
                  end
                },
                { 
                  label = _"Verified at",
                  content = function(record)
                    ui.tag{ content = format.timestamp(record.verified) }
                  end
                },
                { 
                  label = _"Verified by",
                  content = function(record)
                    if record.verifying_member_id then
                      local member = Member:by_id(record.verifying_member_id)
                      ui.link{ module = "member", view = "show", id = member.id, content = member.identification or (member.id .. " " .. member.name) }
                      local state = string.match(record.comment, "[^/]+$")
                      slot.put(" ")
                      ui.tag{ content = state } 
                    elseif record.verified then
                      ui.tag{ content = _"automatically verified" }
                    end
                    
                  end
                },
              }
            }
          end
        elseif mode == "not_activated" then
          verifications_selector:add_where("member.activated ISNULL")
          :add_order_by("verification.id DESC")
          local verifications = verifications_selector:exec()
          execute.view{ module = "registration_admin", view = "_verification_list", params = { verifications = verifications } }
        end
          
      end }
    end }

  end }
end }

