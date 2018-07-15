local initiative = param.get("initiative", "table")
local direct_supporter
if app.session.member_id then
  direct_supporter = initiative.issue.member_info.own_participation and initiative.member_info.supported
end


ui.link { attr = { name = "suggestions" }, text = "" }


ui.container {
  attr = { class = "section suggestions" },
  content = function ()

    if # ( initiative.suggestions ) > 0 then
  
      ui.heading { 
        level = 1, 
        content = _("Suggestions for improvement (#{count})", { count = # ( initiative.suggestions ) } ) 
      }
      ui.container { content = _"written and rated by the supportes of this initiative to improve the proposal and its reasons" }
      slot.put("<br />")
      
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
              content = format.string(suggestion.name, {
              truncate_at = 160, truncate_suffix = true
            }) }

            if opinion then
              
              ui.container { attr = { class = "mdl-card__content"}, content = function()
                local class = ""
                local text = ""
                
                if opinion.degree == 2 then
                  class = "must"
                  text = _"must"
                elseif opinion.degree == 1 then
                  class = "should"
                  text = _"should"
                elseif opinion.degree == 0 then
                  class = "neutral"
                  text = _"neutral"
                elseif opinion.degree == -1 then
                  class = "shouldnot"
                  text = _"should not"
                elseif opinion.degree == -2 then
                  class = "mustnot"
                  text = _"must not"
                end
                
                ui.tag { 
                  attr = { class = class }, 
                  content = text 
                }
                
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
                
                local class = ""
                local text = ""
                
                if opinion.fulfilled then
                  class = "implemented"
                  text = _"is implemented"
                else
                  class = "notimplemented"
                  text = _"is not implemented"
                end

                ui.tag { 
                  attr = { class = class }, 
                  content = text
                }

                if 
                  (opinion.degree > 0 and not opinion.fulfilled)
                  or (opinion.degree < 0 and opinion.fulfilled)
                then
                  if math.abs(opinion.degree) > 1 then
                    slot.put(" !!")
                  else
                    slot.put(" !")
                  end
                else
                  slot.put(" ✓")
                end

              end }

            end
              
          end }
      
          ui.container{ attr = { class = "suggestion-content" }, content = function()
        
            local plus2  = (suggestion.plus2_unfulfilled_count or 0)
                + (suggestion.plus2_fulfilled_count or 0)
            local plus1  = (suggestion.plus1_unfulfilled_count  or 0)
                + (suggestion.plus1_fulfilled_count or 0)
            local minus1 = (suggestion.minus1_unfulfilled_count  or 0)
                + (suggestion.minus1_fulfilled_count or 0)
            local minus2 = (suggestion.minus2_unfulfilled_count  or 0)
                + (suggestion.minus2_fulfilled_count or 0)
            
            local with_opinion = plus2 + plus1 + minus1 + minus2

            local neutral = (suggestion.initiative.supporter_count or 0)
                - with_opinion

            local neutral2 = with_opinion 
                  - (suggestion.plus2_fulfilled_count or 0)
                  - (suggestion.plus1_fulfilled_count or 0)
                  - (suggestion.minus1_fulfilled_count or 0)
                  - (suggestion.minus2_fulfilled_count or 0)
            
            ui.container { 
              attr = { class = "mdl-card__content mdl-card--border suggestionInfo" },
              content = function ()
              
                if app.session:has_access("authors_pseudonymous") then
                  util.micro_avatar ( suggestion.author )
                end
                
                if with_opinion > 0 then
                  ui.container { attr = { class = "suggestion-rating" }, content = function ()
                    ui.tag { content = _"collective rating:" }
                    slot.put("&nbsp;")
                    ui.bargraph{
                      max_value = suggestion.initiative.supporter_count,
                      width = 100,
                      bars = {
                        { color = "#0a0", value = plus2 },
                        { color = "#8a8", value = plus1 },
                        { color = "#eee", value = neutral },
                        { color = "#a88", value = minus1 },
                        { color = "#a00", value = minus2 },
                      }
                    }
                    slot.put(" | ")
                    ui.tag { content = _"implemented:" }
                    slot.put ( "&nbsp;" )
                    ui.bargraph{
                      max_value = with_opinion,
                      width = 100,
                      bars = {
                        { color = "#0a0", value = suggestion.plus2_fulfilled_count },
                        { color = "#8a8", value = suggestion.plus1_fulfilled_count },
                        { color = "#eee", value = neutral2 },
                        { color = "#a88", value = suggestion.minus1_fulfilled_count },
                        { color = "#a00", value = suggestion.minus2_fulfilled_count },
                      }
                    }
                  end }
                end

              end 
            }
                
            ui.container {
              attr = { class = "mdl-card__content mdl-card--border suggestion-text draft" },
              content = function ()
                slot.put ( suggestion:get_content( "html" ) )
               
              end
            }
 
            if direct_supporter then
              ui.container{ attr = { class = "mdl-card__content rating" }, content = function ()

                if not opinion then
                  opinion = {}
                end
                ui.form { 
                  module = "opinion", action = "update", params = {
                    suggestion_id = suggestion.id
                  },
                  routing = { default = {
                    mode = "redirect", 
                    module = "initiative", view = "show", id = suggestion.initiative_id,
                    params = { suggestion_id = suggestion.id },
                    anchor = "s" .. suggestion.id -- TODO webmcp
                  } },
                  content = function ()
                    
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
                        local active = opinion.degree == option.degree
                        ui.tag{
                          tag = "label", 
                          attr = { class = "mdl-radio mdl-js-radio mdl-js-ripple-effect" }, 
                          ["for"] = "s" .. suggestion.id .. "_degree" .. option.degree, 
                          content = function()
                            ui.tag{
                              tag = "input",
                              attr = {
                                class = "mdl-radio__button",
                                type = "radio",
                                name = "degree",
                                value = option.degree,
                                id = "s" .. suggestion.id .. "_degree" .. option.degree,
                                checked = active and "checked" or nil
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
                        local active = opinion.fulfilled == (option.degree == "true" and true or false)
                        ui.tag{
                          tag = "label", 
                          attr = { class = "mdl-radio mdl-js-radio mdl-js-ripple-effect" }, 
                          ["for"] = "s" .. suggestion.id .. "_" .. option.id, 
                          content = function()
                            ui.tag{
                              tag = "input",
                              attr = {
                                class = "mdl-radio__button",
                                type = "radio",
                                name = "fulfilled",
                                value = option.degree,
                                id = "s" .. suggestion.id .. "_" .. option.id,
                                checked = active and "checked" or nil
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
                    
                  end 
                }

              end }
            end
            
          end }

          ui.container { attr = { class = "rating-button" }, content = function()
          
            local text = _"Read more"
            
            if direct_supporter then
              text = text .. " / " .. _"Rate suggestion"
            end
              
            ui.link { 
              attr = { 
                class = "mdl-button mdl-js-button suggestion-more",
                onclick = "document.querySelector('#s" .. suggestion.id .. "').classList.remove('folded');document.querySelector('#s" .. suggestion.id .. "').classList.add('unfolded'); return false;"
              },
              text = text
            }
            
            ui.link { 
              attr = { 
                class = "mdl-button suggestion-less",
                onclick = "document.querySelector('#s" .. suggestion.id .. "').classList.add('folded');document.querySelector('#s" .. suggestion.id .. "').classList.remove('unfolded'); return false;"
              },
              text = _"Show less"
            }
            --[[
            ui.link{
              attr = { class = "mdl-button" },
              content = _"Details",
              module = "suggestion", view = "show", id = suggestion.id
            }
            --]]
          end }
          ui.script{ script = [[
            window.addEventListener("load", function() {
              var textEl = document.querySelector('#s]] .. suggestion.id .. [[ .suggestion-content');
              var height = textEl.clientHeight;
              if (height > 180) {
                document.querySelector('#s]] .. suggestion.id .. [[').classList.add('folded');
                document.querySelector('#s]] .. suggestion.id .. [[ .rating-button').classList.add('mdl-card__actions');
                document.querySelector('#s]] .. suggestion.id .. [[ .rating-button').classList.add('mdl-card--border');
              }
            });
          ]] }
          
        end } 

      end -- for i, suggestion
    
    end -- if #initiative.suggestions > 0
  end
}
