ui.title(function()
  ui.link { module = "registration_admin", view = "index", content = _"Role management" }
  slot.put ( " » " )
  ui.tag { tag = "span", content = "Rejected requests"}
end)
app.html_title.title = _"Role management"

ui.container{ attr = { class = "mdl-grid" }, content = function()
  ui.container{ attr = { class = "mdl-cell mdl-cell--12-col" }, content = function()

    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = function()
          ui.tag{ content = _"Rejected role accreditation requests" }
        end }
      end }

      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()

        local verifications = RoleVerification:new_selector()
          :add_where("denied NOTNULL")
          :add_order_by("requested DESC")
          :exec()
          
        if #verifications > 0 then
          execute.view{ module = "registration_admin", view = "_role_verification_list", params = { verifications = verifications } }
        end
      
      end }
    end }


  end }
end }

