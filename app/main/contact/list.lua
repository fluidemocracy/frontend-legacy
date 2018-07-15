local contacts_selector = Contact:build_selector{
  member_id = app.session.member_id,
  order = "name"
}

ui.title(_"Contacts")

ui.grid{ content = function()
  ui.cell_main{ content = function()

    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Contacts" }
      end }
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()


        ui.paginate{
          selector = contacts_selector,
          content = function()
            local contacts = contacts_selector:exec()
            if #contacts == 0 then
              ui.field.text{ value = _"You didn't save any member as contact yet." }
            else
              ui.list{
                attr = { class = "mdl-data-table mdl-js-data-table mdl-shadow--2dp" },
                records = contacts,
                columns = {
                  {
                    label = _"Name",
                    content = function(record)
                      ui.link{
                        text = record.other_member.name,
                        module = "member",
                        view = "show",
                        id = record.other_member_id
                      }
                    end
                  },
                  {
                    label = _"Published",
                    content = function(record)
                      ui.field.boolean{ value = record.public }
                    end
                  },
                  {
                    content = function(record)
                      if record.public then
                        ui.link{
                          attr = { class = "action" },
                          text = _"Hide",
                          module = "contact",
                          action = "add_member",
                          id = record.other_member_id,
                          params = { public = false },
                          routing = {
                            default = {
                              mode = "redirect",
                              module = request.get_module(),
                              view = request.get_view(),
                              id = request.get_id_string(),
                              params = request.get_param_strings()
                            }
                          }
                        }
                      else
                        ui.link{
                          attr = { class = "action" },
                          text = _"Publish",
                          module = "contact",
                          action = "add_member",
                          id = record.other_member_id,
                          params = { public = true },
                          routing = {
                            default = {
                              mode = "redirect",
                              module = request.get_module(),
                              view = request.get_view(),
                              id = request.get_id_string(),
                              params = request.get_param_strings()
                            }
                          }
                        }
                      end
                    end
                  },
                  {
                    content = function(record)
                      ui.link{
                        attr = { class = "action" },
                        text = _"Remove",
                        module = "contact",
                        action = "remove_member",
                        id = record.other_member_id,
                        routing = {
                          default = {
                            mode = "redirect",
                            module = request.get_module(),
                            view = request.get_view(),
                            id = request.get_id_string(),
                            params = request.get_param_strings()
                          }
                        }
                      }
                    end
                  },
                }
              }
            end
          end
        }

      end }
    end }
  end }
end }
