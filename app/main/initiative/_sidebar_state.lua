local initiative = param.get("initiative", "table")


-- voting results
if initiative.issue.fully_frozen and initiative.issue.closed and initiative.admitted
  and initiative.issue.voter_count then
  local class = initiative.winner and "sectionRow admitted_info" or "sectionRow not_admitted_info"
  ui.container{
    attr = { class = class },
    content = function()
      local max_value = initiative.issue.voter_count
      local positive_votes = initiative.positive_votes
      local negative_votes = initiative.negative_votes
      local abstention_votes = max_value - 
              negative_votes - 
              positive_votes
      local head_text

      util.initiative_pie( initiative )
      
      if initiative.winner then
        head_text = _"Approved"
      elseif initiative.rank then
        head_text = _("Rejected (rank #{rank})", { rank = initiative.rank })
      else
        head_text = _"Rejected"
      end

      ui.heading { level = 1, content = head_text }
      
      ui.tag { tag = "table", content = function ()
        ui.tag { tag = "tr", attr = { class = "yes" }, content = function ()
          ui.tag { tag = "td", content = 
            tostring(positive_votes) 
          }
          ui.tag { tag = "th", content = _"Yes" }
          ui.tag { tag = "td", content = 
            format.percent_floor(positive_votes, max_value) 
          }
          ui.tag { tag = "th", content = _"Yes" }
        end }
        ui.tag { tag = "tr", attr = { class = "no" }, content = function ()
          ui.tag { tag = "td", content = 
            tostring(negative_votes)
          }
          ui.tag { tag = "th", content = _"No" }
          ui.tag { tag = "td", content =
            format.percent_floor(negative_votes, max_value) 
          }
          ui.tag { tag = "th", content = _"No" }
        end }
        ui.tag { tag = "tr", attr = { class = "abstention" }, content = function ()
          ui.tag { tag = "td", content = 
            tostring(abstention_votes)
          }
          ui.tag { tag = "th", content = _"Abstention" }
          ui.tag { tag = "td", content =
            format.percent_floor(abstention_votes, max_value) 
          }
          ui.tag { tag = "th", content = _"Abstention" }
        end }
      end }
    end
  }
end
  
-- initiative not admitted info
if initiative.admitted == false then
  local policy = initiative.issue.policy
  ui.container{
    attr = { class = "draft mdl-card__content mdl-card--border" },
    content = function ()
      ui.heading { level = 1, content = _"Initiative not admitted" }
      local num = policy.initiative_quorum_num                                                                                                        
      local den = policy.initiative_quorum_den                                                                                                        
      local quorums = {}                                                                                                                              
      if num and num > 0 and den == 100 or den == 10 then                                                                                             
        table.insert(quorums, _("#{percentage}%", { percentage = num * 100 / den }))                                                                  
      elseif num and num > 0 and den and den > 0 then                                                                                                 
        table.insert(quorums, num .. "/" .. den)                                                                                                      
      end                                                                                                                                             
      if policy.initiative_quorum then                                                                                                                
        table.insert(quorums, policy.initiative_quorum)                                                                                               
      end                                                                                                                                             
      local quorum = table.concat(quorums, " / ")                                                                                                     
                                                                                                                                                      
      ui.container { content = _("This initiative has not been admitted! It failed the 2nd quorum of #{quorum}.", { quorum = quorum } ) }             
    end
  }
end

-- initiative revoked info
if initiative.revoked then
  ui.container{
    attr = { class = "draft mdl-card__content mdl-card--border" },
    content = function()
      ui.heading { level = 1, content = _"Initiative revoked" }
      slot.put(_("This initiative has been revoked at #{revoked} by:", {
        revoked = format.timestamp(initiative.revoked)
      }))
      slot.put(" ")
      if app.session:has_access("authors_pseudonymous") then
        ui.link{
          module = "member", view = "show", id = initiative.revoked_by_member_id,
          content = initiative.revoked_by_member.name
        }
      else
        ui.tag{ content = _"[Not public]" }
      end
      local suggested_initiative = initiative.suggested_initiative
      if suggested_initiative then
        slot.put("<br /><br />")
        slot.put(_("The initiators suggest to support the following initiative:"))
        slot.put("<br />")
        ui.link{
          content = suggested_initiative.display_name,
          module = "initiative",
          view = "show",
          id = suggested_initiative.id
        }
      end
    end
  }
end
 
