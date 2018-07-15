local member = param.get("member", "table")

local events = Event:by_member_id(member.id)

local last_date

for i, event in ipairs(events) do
  
  ui.container{ content = function()
  
    local date = atom.date(event.occurrence)
    if date ~= last_date then
      last_date = date
      ui.heading{ level = 3, content = format.date(date) }
    end
    
    local date_dumped = atom.dump(event.occurrence)
    local time = atom.time:load(string.sub(date_dumped, 12, #date_dumped))
    
    ui.tag{ content = format.time(time) }
    
    slot.put(" ")
    
    if event.event == "member_active" then
      ui.tag{ content = _"account activated" }
    end
    
    if event.event == "initiative_created_in_new_issue" then
      ui.tag{ content = _("created #{initiative} (as new issue)", { initiative = event.initiative.display_name }) }
    end
    
    if event.event == "interest" then
      if event.value == 1 then
        ui.tag{ content = _("added interest to #{issue}", { issue = event.issue.name }) }
      else
        ui.tag{ content = _"removed interest" }
      end
    end

    if event.event == "support" then
      if event.value == 1 then
        ui.tag{ content = _("added support to #{initiative}", { initiative = event.initiative.display_name }) }
      else
        ui.tag{ content = _"removed support" }
      end
    end

  end }
  
  
end
