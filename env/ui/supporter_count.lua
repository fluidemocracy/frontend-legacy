function ui.supporter_count(initiative)
  if initiative.supporter_count == nil then
    ui.tag { 
      attr = { class = "supporterCount" },
      content = _"[calculating]"
    }
  elseif initiative.issue.closed == nil then
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
