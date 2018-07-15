ui.title(_"Usermanagement")
app.html_title.title = _"Usermanagement"

ui.container{ attr = { class = "mdl-grid" }, content = function()
  ui.container{ attr = { class = "mdl-cell mdl-cell--12-col" }, content = function()

    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = function()
          ui.tag{ content = _"Usermanagement" }
        end }
      end }

      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()

        ui.container{ content = _"User accounts" }
      
        ui.tag{ tag = "ul", content = function()

          local count = Verification:new_selector()
            :add_where("verified_member_id ISNULL")
            :add_where("denied ISNULL")
            :count()
          ui.tag{ tag = "li", content = function()
            ui.link{ module = "registration_admin", view = "verification_requests", content = _("Open requests (#{count})", { count = count }) }
          end }
          
          ui.tag{ tag = "ul", content = function()
          
            local count = Verification:new_selector()
              :add_where("verified_member_id ISNULL")
              :add_where("denied ISNULL")
              :add_where("comment ilike '%User requested manual verification (during step 1)'")
              :count()
            ui.tag{ tag = "li", content = function()
              ui.link{ module = "registration_admin", view = "verification_requests", params = { mode = "manual_requested", step = 1 }, content = _("Manual verification requested during step 1 (#{count})", { count = count }) }
            end }
            
            local count = Verification:new_selector()
              :add_where("verified_member_id ISNULL")
              :add_where("denied ISNULL")
              :add_where("comment ilike '%User requested manual verification (during step 2)'")
              :count()
            ui.tag{ tag = "li", content = function()
              ui.link{ module = "registration_admin", view = "verification_requests", params = { mode = "manual_requested", step = 2 }, content = _("Manual verification requested during step 2 (#{count})", { count = count }) }
            end }
            
            local count = Verification:new_selector()
              :add_where("verified_member_id ISNULL")
              :add_where("denied ISNULL")
              :add_where("comment ilike '% sent'")
              :count()
            ui.tag{ tag = "li", content = function()
              ui.link{ module = "registration_admin", view = "verification_requests", params = { mode = "pin_sent" }, content = _("PIN code not entered (yet) (#{count})", { count = count }) }
            end }
            
            local count = Verification:new_selector()
              :add_where("verified_member_id ISNULL")
              :add_where("denied ISNULL")
              :add_where("comment similar to '%fiscal code does not match[^/]*'")
              :count()
            ui.tag{ tag = "li", content = function()
              ui.link{ module = "registration_admin", view = "verification_requests", params = { mode = "fiscal_code" }, content = _("Fiscal code does not match (#{count})", { count = count }) }
            end }
            
            local count = Verification:new_selector()
              :add_where("verified_member_id ISNULL")
              :add_where("denied ISNULL")
              :add_where("comment ilike '%mobile phone number already used before'")
              :count()
            ui.tag{ tag = "li", content = function()
              ui.link{ module = "registration_admin", view = "verification_requests", params = { mode = "mobile_phone" }, content = _("Phone number used before (#{count})", { count = count }) }
            end }
            
            local count = Verification:new_selector()
              :add_where("verified_member_id ISNULL")
              :add_where("denied ISNULL")
              :add_where("comment ilike '%user with same name already exist'")
              :count()
            ui.tag{ tag = "li", content = function()
              ui.link{ module = "registration_admin", view = "verification_requests", params = { mode = "identification" }, content = _("Identification used before (#{count})", { count = count }) }
            end }
            
            local count = Verification:new_selector()
              :add_where("verified_member_id ISNULL")
              :add_where("denied ISNULL")
              :add_where("comment ilike '%user entered invalid PIN three times'")
              :count()
            ui.tag{ tag = "li", content = function()
              ui.link{ module = "registration_admin", view = "verification_requests", params = { mode = "invalid_pin" }, content = _("Invalid PIN entered (#{count})", { count = count }) }
            end }
            
            local count = Verification:new_selector()
              :add_where("verified_member_id ISNULL")
              :add_where("denied ISNULL")
              :add_where("comment ilike '%user with same name already exists'")
              :count()
            ui.tag{ tag = "li", content = function()
              ui.link{ module = "registration_admin", view = "verification_requests", params = { mode = "same_name_already_exists" }, content = _("User with same name already exists (#{count})", { count = count }) }
            end }
            
            local count = Verification:new_selector()
              :add_where("verified_member_id ISNULL")
              :add_where("denied ISNULL")
              :add_where("not comment ilike '%User requested manual verification'")
              :add_where("not comment ilike '% sent'")
              :add_where("not comment similar to '%fiscal code does not match[^/]*'")
              :add_where("not comment ilike '%mobile phone number already used before'")
              :add_where("not comment ilike '%user with same name already exist'")
              :add_where("not comment ilike '%user entered invalid PIN three times'")
              :add_where("not comment ilike '%user with same name already exists'")
              :count()
            ui.tag{ tag = "li", content = function()
              ui.link{ module = "registration_admin", view = "verification_requests", params = { mode = "other" }, content = _("other reasons (#{count})", { count = count }) }
            end }
          end }
          
          local count = Verification:new_selector()
            :join("member", nil, "member.id = verification.verified_member_id")
            :count()
          ui.tag{ tag = "li", content = function()
            ui.link{ module = "registration_admin", view = "verification_accredited", content = _("Accredited (#{count})", { count = count }) }
            ui.tag{ tag = "ul", content = function()
            
              local count = Verification:new_selector()
                :join("member", nil, "member.id = verification.verified_member_id")
                :add_where("member.activated ISNULL")
                :add_where("member.deleted ISNULL")
                :count()
              ui.tag{ tag = "li", content = function()
                ui.link{ module = "registration_admin", view = "verification_accredited", params = { mode = "not_activated" }, content = _("Account not activated (yet) (#{count})", { count = count }) }
              end }
              
              local count = Verification:new_selector()
                :join("member", nil, "member.id = verification.verified_member_id")
                :add_where("member.activated NOTNULL")
                :add_where("member.deleted ISNULL")
                :count()
              ui.tag{ tag = "li", content = function()
                ui.link{ module = "registration_admin", view = "verification_accredited", params = { mode = "activated" }, content = _("Activated accounts (#{count})", { count = count }) }
              end }
              
              local count = Verification:new_selector()
                :join("member", nil, "member.id = verification.verified_member_id")
                :add_where("member.deleted NOTNULL")
                :count()
              ui.tag{ tag = "li", content = function()
                ui.link{ module = "registration_admin", view = "verification_cancelled", content = _("Cancelled accounts (#{count})", { count = count }) }
              end }
            end }
          end }
          
          local count = Verification:new_selector()
            :add_where("denied NOTNULL")
            :count()
          ui.tag{ tag = "li", content = function()
            ui.link{ module = "registration_admin", view = "verification_rejected", content = _("Rejected requests (#{count})", { count = count }) }
          end }
          
        end }

        ui.container{ content = _"Role accounts" }
      
        ui.tag{ tag = "ul", content = function()

          local count = RoleVerification:new_selector()
            :add_where("verified ISNULL")
            :add_where("denied ISNULL")
            :count()
          ui.tag{ tag = "li", content = function()
            ui.link{ module = "registration_admin", view = "role_verification_requests", content = _("Open requests (#{count})", { count = count }) }
          end }
          
          local count = RoleVerification:new_selector()
            :add_where("verified NOTNULL")
            :add_where("denied ISNULL")
            :join("member", nil, "member.id = role_verification.verified_member_id")
            :add_where("member.deleted ISNULL")
            :count()
          ui.tag{ tag = "li", content = function()
            ui.link{ module = "registration_admin", view = "role_verification_accredited", content = _("Accredited (#{count})", { count = count }) }
          end }
          
          local count = RoleVerification:new_selector()
            :add_where("verified NOTNULL")
            :add_where("denied ISNULL")
            :join("member", nil, "member.id = role_verification.verified_member_id")
            :add_where("member.deleted NOTNULL")
            :count()
          ui.tag{ tag = "li", content = function()
            ui.link{ module = "registration_admin", view = "role_verification_cancelled", content = _("Cancelled (#{count})", { count = count }) }
          end }
          
          local count = RoleVerification:new_selector()
            :add_where("verified ISNULL")
            :add_where("denied NOTNULL")
            :count()
          ui.tag{ tag = "li", content = function()
            ui.link{ module = "registration_admin", view = "role_verification_rejected", content = _("Rejected (#{count})", { count = count }) }
          end }
          
          
        end }

      end }
    end }



  end }
end }

