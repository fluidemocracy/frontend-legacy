local initiative = param.get("initiative", "table")
local direct_supporter
if app.session.member_id then
  direct_supporter = initiative.issue.member_info.own_participation and initiative.member_info.supported
end


if direct_supporter then
  ui.tag{ tag = "dialog", attr = { id = "rating_dialog" }, content = function ()

    local opinion = {}
    ui.form { 
      attr = { onsubmit = "updateOpinion(); return false;" },
      module = "opinion", action = "update",
      routing = { default = {
        mode = "redirect", 
        module = "initiative", view = "show", id = initiative.id
      } },
      content = function ()
        ui.field.hidden{ attr = { id = "rating_suggestion_id" }, name = "suggestion_id" }        
        ui.container{ attr = { class = "opinon-question" }, content = _"Should the initiator implement this suggestion?" }
        ui.container { content = function ()
        
          local options = {
            { degree =  2, label = _"must" },
            { degree =  1, label = _"should" },
            { degree =  0, label = _"neutral" },
            { degree = -1, label = _"should not" },
            { degree = -2, label = _"must not" },
          }
          
          for i, option in ipairs(options) do
            ui.tag{
              tag = "label", 
              attr = { 
                id = "rating_degree" .. option.degree,
                class = "mdl-radio mdl-js-radio mdl-js-ripple-effect"
              }, 
              ["for"] = "rating_degree" .. option.degree, 
              content = function()
                ui.tag{
                  tag = "input",
                  attr = {
                    class = "mdl-radio__button",
                    type = "radio",
                    name = "degree",
                    value = option.degree
                  }
                }
                ui.tag{
                  attr = { class = "mdl-radio__label" },
                  content = option.label
                }
              end
            }
            slot.put(" &nbsp;&nbsp;&nbsp; ")
          end
        end }
        
        slot.put("<br />")

        ui.container{ attr = { class = "opinon-question" }, content = _"Did the initiator implement this suggestion?" }
        ui.container { content = function ()

          local options = {
            { degree = "false", id = "notfulfilled", label = _"No (not yet)" },
            { degree = "true", id = "fulfilled", label = _"Yes, it's implemented" },
          }
          
          for i, option in ipairs(options) do
            ui.tag{
              tag = "label", 
              attr = {
                id = "rating_" .. option.id,
                class = "mdl-radio mdl-js-radio mdl-js-ripple-effect"
              }, 
              ["for"] = "rating_" .. option.id, 
              content = function()
                ui.tag{
                  tag = "input",
                  attr = {
                    class = "mdl-radio__button",
                    type = "radio",
                    name = "fulfilled",
                    value = option.degree,
                  }
                }
                ui.tag{
                  attr = { class = "mdl-radio__label" },
                  content = option.label
                }
              end
            }
            slot.put(" &nbsp;&nbsp;&nbsp; ")
          end
        end }
    
        slot.put("<br />")
        
        ui.tag{
          tag = "input",
          attr = {
            type = "submit",
            class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored",
            value = _"publish my rating"
          },
          content = ""
        }
        
        slot.put(" &nbsp; ")
        
        ui.tag{
          tag = "input",
          attr = {
            onclick = "document.getElementById('rating_dialog').close(); return false;",
            type = "submit",
            class = "mdl-button mdl-js-button",
            value = _"cancel"
          },
          content = ""
        }
        
      end 
    }

  end }
end


ui.link { attr = { name = "suggestions" }, text = "" }

ui.container {
  attr = { class = "section suggestions" },
  content = function ()

    ui.heading { 
      level = 1, 
      content = _("Suggestions for improvement (#{count})", { count = # ( initiative.suggestions ) } ) 
    }

    ui.container { content = _"written and rated by the supportes of this initiative to improve the proposal and its reasons" }

    if initiative.member_info.supported and not active_trustee_id then
      ui.link {
        attr = {
            style = "margin-top: 1ex;",
            class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored",
        },
        module = "suggestion", view = "new", params = {
          initiative_id = initiative.id
        },
        content = _"write a new suggestion" 
      }
    end

    slot.put("<br /><br />")

    for i, suggestion in ipairs(initiative.suggestions) do

      local opinion = Opinion:by_pk(app.session.member_id, suggestion.id)

      local class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp not-folded"
      if suggestion.id == param.get("suggestion_id", atom.number) then
        class = class .. " highlighted"
      end
      if member and not initiative.issue.fully_frozen and not initiative.issue.closed and initiative.member_info.supported then
        class = class .. " rateable"
      end
    
      ui.link { attr = { name = "s" .. suggestion.id }, text = "" }
      ui.tag { tag = "div", attr = { class = class, id = "s" .. suggestion.id }, content = function ()
        ui.tag{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
          ui.heading { level = 2, 
            attr = { class = "mdl-card__title-text" },
            content = function()
              ui.tag{ content = format.string(suggestion.name, {
                truncate_at = 160, truncate_suffix = true })
              }
            end
          }
        end }

          
    
        ui.container{ attr = { class = "suggestion-content" }, content = function()
      
          ui.container { 
            attr = { class = "mdl-card__content mdl-card--border suggestionInfo" },
            content = function ()
            
              if app.session:has_access("authors_pseudonymous") then
                ui.tag{ content = _"by" }
                slot.put(" ")
                ui.link{
                  module = "member", view = "show", id = suggestion.author_id,
                  content = suggestion.author.name
                }
              end
              
              execute.view{
                module = "suggestion", view = "_collective_rating", params = {
                  suggestion = suggestion
                }
              }

            end 
          }
              
          ui.container {
            attr = { class = "mdl-card__content suggestion-text draft" },
            content = function ()
              slot.put ( suggestion:get_content( "html" ) )

              ui.container { attr = { class = "floatx-right" }, content = function()
              
                ui.link { 
                  attr = { 
                    class = "mdl-button mdl-js-button mdl-button--icon suggestion-more",
                    onclick = "document.querySelector('#s" .. suggestion.id .. "').classList.remove('folded');document.querySelector('#s" .. suggestion.id .. "').classList.add('unfolded'); return false;"
                  },
                  content = function()
                    ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "expand_more" }
                  end
                }
                
                ui.link { 
                  attr = { 
                    class = "mdl-button mdl-js-button mdl-button--icon suggestion-less",
                    onclick = "document.querySelector('#s" .. suggestion.id .. "').classList.add('folded');document.querySelector('#s" .. suggestion.id .. "').classList.remove('unfolded'); return false;"
                  },
                  content = function()
                    ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "expand_less" }
                  end
                }
                --[[
                ui.link{
                  attr = { class = "mdl-button" },
                  content = _"Details",
                  module = "suggestion", view = "show", id = suggestion.id
                }
                --]]
              end }
             
            end
          }

        end }

        ui.container { attr = { class = "mdl-card__actions mdl-card--border" }, content = function()

          if direct_supporter then
            ui.container{ attr = { class = "suggestion_rating_info" }, content = function()
              ui.tag{ attr = { id = "s" .. suggestion.id .. "_rating_text" }, content = function()
                local text = ""
                if opinion then
                  if opinion.degree == 2 then
                    text = _"must"
                  elseif opinion.degree == 1 then
                    text = _"should"
                  elseif opinion.degree == 0 then
                    text = _"neutral"
                  elseif opinion.degree == -1 then
                    text = _"should not"
                  elseif opinion.degree == -2 then
                    text = _"must not"
                  end
                  ui.tag { content = text }
                  slot.put ( " " )
                  if 
                    (opinion.degree > 0 and not opinion.fulfilled)
                    or (opinion.degree < 0 and opinion.fulfilled)
                  then
                    ui.tag{ content = _"but" }
                  else
                    ui.tag{ content = _"and" }
                  end
                  slot.put ( " " )
                  local text = ""
                  if opinion.fulfilled then
                    text = _"is implemented"
                  else
                    text = _"is not implemented"
                  end
                  ui.tag { content = text }
                end
              end }
              local id = "s" .. suggestion.id .. "_rating_icon"
              if opinion and (
                  (opinion.degree > 0 and not opinion.fulfilled)
                  or (opinion.degree < 0 and opinion.fulfilled)
                )
              then
                slot.put(" ")
                if math.abs(opinion.degree) > 1 then
                  ui.icon("warning", "red", id)
                else
                  ui.icon("warning", nil, id)
                end
              elseif opinion then
                slot.put(" ")
                ui.icon("done", nil, id)
              else
                slot.put(" ")
                ui.icon("blank", nil, id)
              end
            end }
            
            ui.link{
              attr = {
                id = "s" .. suggestion.id .. "_rate_button",
                class = "mdl-button",
                onclick = "rateSuggestion(" .. suggestion.id .. ", " .. (opinion and opinion.degree or 0) .. ", " .. (opinion and (opinion.fulfilled and "true" or "false") or "null") .. ");return false;"
              },
              content = function()
                if opinion then
                  ui.tag { content = _"update rating" }
                else
                  ui.tag { content = _"rate suggestion" }
                end
              end
            }
          end
                    
          ui.link{
            attr = { class = "mdl-button" },
            content = _"Details",
            module = "suggestion", view = "show", id = suggestion.id
          }

        end }
        ui.script{ script = [[
          var rateSuggestionRateText = "]] .. _"rate suggestion" .. [[";
          var rateSuggestionUpdateRatingText = "]] .. _"update rating" .. [[";
          var rateSuggestionDegreeTexts = {
            "-2": "]] .. _"must not" .. [[",
            "-1": "]] .. _"should not" .. [[",
            "1": "]] .. _"should" .. [[",
            "2": "]] .. _"must" .. [["
          }
          var rateSuggestionAndText = "]] .. _"and" .. [[";
          var rateSuggestionButText = "]] .. _"but" .. [[";
          var rateSuggestionFulfilledText = "]] .. _"is implemented" .. [[";
          var rateSuggestionNotFulfilledText = "]] .. _"is not implemented" .. [[";
          window.addEventListener("load", function() {
            var textEl = document.querySelector('#s]] .. suggestion.id .. [[ .suggestion-content');
            var height = textEl.clientHeight;
            if (height > 250) {
              document.querySelector('#s]] .. suggestion.id .. [[').classList.add('folded');
            }
          });
        ]] }
        
      end } 

    end -- for i, suggestion
  
  end
}
