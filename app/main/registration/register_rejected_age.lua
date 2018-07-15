ui.title(_"Self registration")
app.html_title.title = _"Self registration"

ui.container{ attr = { class = "mdl-grid" }, content = function()
  ui.container{ attr = { class = "mdl-cell mdl-cell--12-col" }, content = function()

    ui.heading{ content = _"Registration rejected" }
    slot.put("<br />")
    ui.container { content = function()
      ui.tag { content = _"Sorry, but you need to be at least 16 years old to participate. You can " }
      ui.link{ content = _"browse the platform as a guest", module = "index", view = "index" }
      ui.tag{ content = "." }
    end }
    slot.put("<br />")

    
  end }
end }
