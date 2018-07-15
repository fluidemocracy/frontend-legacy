ui.title(_"Self registration")
app.html_title.title = _"Self registration"

ui.container{ attr = { class = "mdl-grid" }, content = function()
  ui.container{ attr = { class = "mdl-cell mdl-cell--12-col" }, content = function()

    ui.heading{ content = _"Manual verification needed" }
    slot.put("<br />")
    ui.container { content = function()
      ui.tag{ content = "We are sorry but the automatic verification of personal data has not been successful. We will need to verify your information manually. We apologise for the wait, and thank you for your cooperation. Until your information is verified, you can continue to " }
      ui.link{ content = _"browse the portal as an unregistered user", module = "index", view = "index" }
      ui.tag{ content = "." }
      slot.put("<br /><br />")
      ui.tag{ content = "For problems related to registration and use of the platform, please email " }
      ui.link{ external = "mailto:" .. config.self_registration.contact_email, content = config.self_registration.contact_email }
      ui.tag{ content = "." }
    end }
    slot.put("<br />")

  end }
end }

