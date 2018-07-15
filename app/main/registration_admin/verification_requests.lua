local mode = param.get("mode")
local step = param.get("step", atom.integer)

local verifications_selector = Verification:new_selector()
  :add_where("verified_member_id ISNULL")
  :add_where("denied ISNULL")
  :add_order_by("requested DESC")

local title = _"Open requests"
  
if mode == "manual_requested" and step == 1 then
  title = _"Manual verification requested during step 1"
  verifications_selector:add_where("comment ilike '%User requested manual verification (during step 1)'")
elseif mode == "manual_requested" and step == 2 then
  title = _"Manual verification requested during step 2"
  verifications_selector:add_where("comment ilike '%User requested manual verification (during step 2)'")
elseif mode == "pin_sent" then
  title = _"PIN code not entered"
  verifications_selector:add_where("comment ilike '% sent'")
elseif mode == "fiscal_code" then
  title = _"Fiscal code does not match"
  verifications_selector:add_where("comment similar to '%fiscal code does not match[^/]*'")
elseif mode == "mobile_phone" then
  title = _"Phone number used before"
  verifications_selector:add_where("comment ilike '%mobile phone number already used before'")
elseif mode == "identification" then
  title = _"Identification used before"
  verifications_selector:add_where("comment ilike '%user with same name already exist'")
elseif mode == "invalid_pin" then
  title = _"Invalid PIN entered"
  verifications_selector:add_where("comment ilike '%user entered invalid PIN three times'")
elseif mode == "same_name_already_exists" then
  title = _"Same name already exists"
  verifications_selector:add_where("comment ilike '%user with same name already exists'")
elseif mode == "other" then
  title = _"Other reasons"
  verifications_selector:add_where("not comment ilike '%User requested manual verification'")
  verifications_selector:add_where("not comment ilike '% sent'")
  verifications_selector:add_where("not comment similar to '%fiscal code does not match[^/]*'")
  verifications_selector:add_where("not comment ilike '%mobile phone number already used before'")
  verifications_selector:add_where("not comment ilike '%user with same name already exist'")
  verifications_selector:add_where("not comment ilike '%user entered invalid PIN three times'")
  verifications_selector:add_where("not comment ilike '%user with same name already exists'")
end

local verifications = verifications_selector:exec()
  

ui.title(function()
  ui.link { module = "registration_admin", view = "index", content = _"Usermanagement" }
  slot.put ( " » " )
  ui.tag { tag = "span", content = _"Open requests" }
end)

app.html_title.title = _"Usermanagement"

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
          execute.view{ module = "registration_admin", view = "_verification_list", params = { verifications = verifications } }
        end
      
      end }
    end }

  end }
end }

