function ui.title ( content )
  
  slot.select ( "title", function ()
    
    -- home link
    ui.link {
      module = "index", view = "index",
      attr = { class = "home", title = _"Home" },
      content = function ()
        ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "home" }
      end
    }
  
    if content then
      ui.tag { attr = { class = "spacer" }, content = function()
        slot.put ( " » " )
      end }
      ui.tag { content = content }
    else
      ui.tag { attr = { class = "spacer" }, content = function()
        slot.put ( " " )
      end }
      ui.tag { content = _"Home" }
    end
    
  end )
  
end
