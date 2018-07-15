ui.title(_"Self registration")
app.html_title.title = _"Self registration"

ui.container{ attr = { class = "mdl-grid" }, content = function()
  ui.container{ attr = { class = "mdl-cell mdl-cell--12-col" }, content = function()

    ui.heading{ content = _"Self registration completed" }
    slot.put("<br />")
    ui.container { content = _"We have sent you an invitation email to finish the account setup." }
    slot.put("<br />")
    ui.container { content = _"Please also check your SPAM folder." }
    slot.put("<br />")

    
  end }
end }
