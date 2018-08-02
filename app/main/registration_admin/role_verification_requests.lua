local mode = param.get("mode")

local verifications_selector = RoleVerification:new_selector()
  :add_where("verified ISNULL")
  :add_where("denied ISNULL")
  :add_order_by("requested DESC")

local title = _"Open role requests"
  
local verifications = verifications_selector:exec()
  

ui.title(function()
  ui.link { module = "registration_admin", view = "index", content = _"Role management" }
  slot.put ( " » " )
  ui.tag { tag = "span", content = _"Open requests" }
end)

app.html_title.title = _"Role management"

ui.container{ attr = { class = "mdl-grid" }, content = function()
  ui.container{ attr = { class = "mdl-cell mdl-cell--12-col" }, content = function()

    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = function()
          ui.tag{ content = title }
        end }
      end }

      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()

        if #verifications > 0 then
          execute.view{ module = "registration_admin", view = "_role_verification_list", params = { verifications = verifications } }
        end
      
      end }
    end }

  end }
end }

