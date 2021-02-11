local suggestion = Suggestion:by_id(param.get_id())

-- redirect to initiative if suggestion does not exist anymore
if not suggestion then
  local initiative_id = param.get('initiative_id', atom.integer)
  if initiative_id then
    slot.reset_all{except={"notice", "error"}}
    request.redirect{
      module='initiative',
      view='show',
      id=initiative_id,
      params = { tab = "suggestions" }
    }
  else
    slot.put_into('error', _"Suggestion does not exist anymore")
  end
  return
end

local initiative = suggestion.initiative

initiative:load_everything_for_member_id(app.session.member_id)
initiative.issue:load_everything_for_member_id(app.session.member_id)



execute.view{ module = "issue", view = "_head", params = { issue = initiative.issue, link_issue = true } }

ui.grid{ content = function()
  ui.cell_main{ content = function()

    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = suggestion.name }
      end }

      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
        if app.session:has_access("authors_pseudonymous") and suggestion.author then 
          util.micro_avatar(suggestion.author)
        end
        execute.view{
          module = "suggestion", view = "_collective_rating", params = {
            suggestion = suggestion
          }
        }
      end }

      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
        slot.put(suggestion:get_content("html"))
      end }

      if app.session:has_access("all_pseudonymous") then
        ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
          execute.view{
            module = "opinion",
            view = "_list",
            params = { 
              opinions_selector = Opinion:new_selector()
                :add_where{ "suggestion_id = ?", suggestion.id }
                :join("member", nil, "member.id = opinion.member_id")
                :add_order_by("member.id DESC")
            }
          }
        end }
      end

    end }
  end }
end }

