function ui.supporter_count(initiative)
  if initiative.supporter_count == nil then
    ui.tag { 
      attr = { class = "supporterCount" },
      content = _"[calculating]"
    }
  elseif initiative.issue.closed == nil then
    if config.token and initiative.issue.area.unit_id == config.token.unit_id then
      ui.tag { 
        attr = { class = "satisfiedSupporterCount" },
        content = _("#{count} #{token_name}", { count = initiative.satisfied_supporter_count / 100, token_name = config.token.token_name })
      }
      if initiative.potential_supporter_count and
          initiative.potential_supporter_count > 0 
      then
        slot.put ( " " )
        ui.tag { 
          attr = { class = "potentialSupporterCount" },
          content = _("(+ #{count} potential)", { count = initiative.potential_supporter_count / 100 })
        }
      end
    else
      ui.tag { 
        attr = { class = "satisfiedSupporterCount" },
        content = _("#{count} supporter", { count = initiative.satisfied_supporter_count })
      }
      if initiative.potential_supporter_count and
          initiative.potential_supporter_count > 0 
      then
        slot.put ( " " )
        ui.tag { 
          attr = { class = "potentialSupporterCount" },
          content = _("(+ #{count} potential)", { count = initiative.potential_supporter_count })
        }
      end
    end
  end 
end
