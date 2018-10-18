local search = param.get("search")

ui.grid{ content = function()

  ui.cell_main{ content = function()
    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Member list" }
      end }
      ui.container{ attr = { class = "mdl-card__content" }, content = function()
        ui.form{
          module = "admin", view = "member_list",
          content = function()
          
            ui.field.text{ label = _"search", name = "search", value = search }
            
            ui.submit{ value = _"search" }
          
          end
        }
  
        local members_selector = Member:build_selector{
          admin_search = search,
          order = "identification"
        }

        ui.paginate{
          selector = members_selector,
          per_page = 30,
          content = function() 
            ui.list{
              records = members_selector:exec(),
              columns = {
                {
                  label = _"Id",
                  content = function(record)
                    ui.link{
                      text = record.id,
                      module = "admin",
                      view = "member_edit",
                      id = record.id
                    }
                  end
                },
                {
                  label = _"Identification",
                  content = function(record)
                    ui.link{
                      text = record.identification or "",
                      module = "admin",
                      view = "member_edit",
                      id = record.id
                    }
                  end
                },
                {
                  label = _"Screen name",
                  content = function(record)
                    ui.link{
                      text = record.name or "",
                      module = "admin",
                      view = "member_edit",
                      id = record.id
                    }
                  end
                },
                {
                  content = function(record)
                    if record.admin then
                      ui.field.text{ value = "admin" }
                    end
                  end
                },
                {
                  content = function(record)
                    if not record.activated then
                      ui.field.text{ value = "not activated" }
                    elseif not record.active then
                      ui.field.text{ value = "inactive" }
                    end
                  end
                },
                {
                  content = function(record)
                    if record.locked then
                      ui.field.text{ value = "locked" }
                    end
                  end
                },
              }
            }
          end
        }
      end }
    end }
  end }
end }
