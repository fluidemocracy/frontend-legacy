local issue = param.get("issue", "table")
local initiative = param.get("initiative", "table")

local view_module
local view_id

if initiative then
  issue = initiative.issue
  view_module = "initiative"
  view_id = initiative.id
else
  view_module = "issue"
  view_id = issue.id
end

local current_occured = false
local failed = false

ui.tag{ tag = "table", content = function()

local function quorum_text(policy, quorum)
  local num
  local den
  
  if quorum == 1 then
    return math.max(policy.issue_quorum or 0, issue.issue_quorum or 0)
  elseif quorum == 2 then
    num = policy.initiative_quorum_num
    den = policy.initiative_quorum_den
  end
  
  if num == nil or den == nil then
    return 0
  end
  
  if den == 100 or den == 10 then
    return _("#{percentage}%", { percentage = num * 100 / den })
  else
    return num .. "/" .. den
  end
  
end

local phases = { "admission", "discussion", "verification", "voting" }

for i, state in ipairs(phases) do
  local current = state == issue.state
  
  if current then
    current_occured = true
  end
  
  local phase_success = (
    (state == "admission" and issue.accepted)
      or (state == "discussion" and issue.half_frozen)
      or (state == "verification" and issue.fully_frozen and issue.state ~= "canceled_no_initiative_admitted")
      or (state == "voting" and issue.closed and issue.state ~= "canceled_no_initiative_admitted" and issue.state ~= "canceled_by_admin")
  )
  
  if not failed then
    ui.container{ tag = "div", attr = { id = "phase-" .. state, class = current and "phase-current" or nil }, content = function()
    
      local state_names = {
        admission = _"Admission",
        discussion = _"Discussion",
        verification = _"Verification",
        voting = _"Voting"
      }
      
      local state_name = state_names[state] or state
      
      local quorum
      if state == "admission" then
        quorum = quorum_text(issue.policy, 1)
      elseif state == "verification" then
        quorum = quorum_text(issue.policy, 2)
      end
      
      local time_text
      if current then
        local time_left
        if issue.state_time_left:sub(1,1) ~= "-" then
          time_text = format.interval_text(issue.state_time_left, { mode = "time_left" })
        else
          time_text = "phase ends soon"
        end
      elseif current_occured then
        local phase_duration = issue[state .. "_time_text"]
        time_text = _("#{duration}", { duration = format.interval_text(phase_duration) } )
      else
        local text = "failed"
        if quorum then
          text = _("failed #{quorum}", { quorum = quorum })
        end
        if phase_success then
          if quorum == 0 then
            text = _"without quorum"
          elseif quorum then
            text = _("reached #{quorum}", { quorum = quorum })
          else
            text = _"finished"
          end
        elseif issue.state == "canceled_revoked_before_accepted" or
            issue.state == "canceled_after_revocation_during_discussion" or
            issue.state == "canceled_after_revocation_during_verification"
        then
          text = _"revoked"
        elseif issue.state == "canceled_by_admin" then
          text = _"canceled"
        end
        time_text = text
      end

      if not config.voting_only or state == "voting" then
        if current then
          ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "play_arrow" }
        elseif not current_occured and not phase_success then
          ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "clear" }
        elseif current_occured and issue.accepted then
          ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "schedule" }
        elseif current_occured then
          ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "lock" }
        else
          ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "check" }
        end

        if not config.voting_only then
          slot.put(" ")
        end

        ui.tag{ attr = { class = "mdl-data-table__cell--non-numeric" }, content = function()
          if not config.voting_only then
            ui.tag{ content = i .. "." }
          end
          slot.put(" ")
          ui.tag{ content = state_name  }
        end}
        ui.tag{ content = " (" .. time_text .. ")"}
      
        slot.put(" ")
          
        if not current then
          ui.tag{ tag = "i", attr = { onclick = "document.getElementById('phase-info-" .. i .. "').classList.toggle('hidden');", class = "material-icons material-icons-small clickable" }, content = "info_outline" }
        end
      end
      
    end }
    
    local help_texts = {
      admission = _("As soon as one initiative of this issue reaches the 1st quorum of #{quorum} support, the issue will proceed to discussion phase.", { quorum = quorum_text(issue.policy, 1) }),
      discussion = _"During the discussion phase, the issue is debated on while the initiators improve the proposals and reasons in their initiatives. Supporters of initiatives can write and rate suggestions for improvement.",
      verification = _("During the verification phase, existing initiatives cannot be changed anymore. Initiatives need to pass the 2nd quorum of #{quorum} at end of verification phase to become admitted for voting.", { quorum = quorum_text(issue.policy, 2) }),
      voting = _"During the voting phase, votes for all admitted initiatives in this issue can be cast. The final result will be calculated as soon as this phase ends."
    }
    
    local class = "phase-info"
    if not current then
      class = class .. " hidden"
    end

    if not config.voting_only then
      ui.container { attr = { id = "phase-info-" .. i, class = class }, content = help_texts[state] }
    end
    
  end
  
  if not phase_success and not current and not current_occured then
    failed = true
  end
end

end }

if issue.closed then
  ui.tag{ content = issue.state_name }
end
