local initiative_id = param.get("initiative_id")

ui.grid{ content = function()

  ui.cell_main{ content = function()
    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Add a new suggestion for improvement" }
      end }
      ui.container{ attr = { class = "mdl-card__content" }, content = function()
        ui.form{
          module = "suggestion",
          action = "add",
          params = { initiative_id = initiative_id },
          routing = {
            default = {
              mode = "redirect",
              module = "initiative",
              view = "show",
              id = initiative_id,
              params = { tab = "suggestions" }
            },
            error = {
              mode = "forward",
              module = "suggestion",
              view = "new",
              params = { initiative_id = initiative_id }
            }
          },
          attr = { class = "section vertical" },
          content = function()
          
            local supported = Supporter:by_pk(initiative_id, app.session.member.id) and true or false
            if not supported then
              ui.field.text{
                attr = { class = "warning" },
                value = _"You are currently not supporting this initiative directly. By adding suggestions to this initiative you will automatically become a potential supporter."
              }
            end

            ui.container{ attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label mdl-card__fullwidth" }, content = function ()
              ui.field.text{
                attr = { id = "lf-initiative__name", class = "mdl-textfield__input" },
                label_attr = { class = "mdl-textfield__label", ["for"] = "lf-initiative__name" },
                label = _"A short title (80 chars max)",
                name  = "name"
              }
            end }

            ui.field.text{
              label = _"Describe how the proposal and/or the reasons of the initiative could be improved",
              name = "content",
              multiline = true, 
              attr = { style = "height: 50ex;" },
              value = param.get("content")
            }

            ui.field.select{
              label = _"How important is your suggestions for you?",
              name = "degree",
              foreign_records = {
                { id =  1, name = _"should be implemented"},
                { id =  2, name = _"must be implemented"},
              },
              foreign_id = "id",
              foreign_name = "name"
            }

            slot.put("<br>")

            ui.submit{ 
              attr = { class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect" },
              text = _"publish suggestion" 
            }
            slot.put(" ")
            ui.link{
              attr = { class = "mdl-button mdl-js-button" },
              content = _"cancel",
              module = "initiative",
              view = "show",
              id = initiative_id,
              params = { tab = "suggestions" }
            }

          end
        }
      end }
    end }
  end }
end }
