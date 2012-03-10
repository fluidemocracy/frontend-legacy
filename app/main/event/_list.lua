local global = param.get("global", atom.boolean)
local for_member = param.get("for_member", "table")
local for_unit = param.get("for_unit", "table")
local for_area = param.get("for_area", "table")

local event_selector = Event:new_selector()
  :add_order_by("event.id DESC")
  :limit(25)
  :join("issue", nil, "issue.id = event.issue_id")

if for_member then
  event_selector:add_where{ "event.member_id = ?", for_member.id }
elseif for_unit then
  event_selector:join("area", nil, "area.id = issue.area_id")
  event_selector:add_where{ "area.unit_id = ?", for_unit.id }
elseif for_area then
  event_selector:add_where{ "issue.area_id = ?", for_area.id }
elseif not global then
  event_selector:join("event_seen_by_member", nil, { "event_seen_by_member.id = event.id AND event_seen_by_member.seen_by_member_id = ?", app.session.member_id })
end
  
if app.session.member_id then
  event_selector
    :left_join("interest", "_interest", { "_interest.issue_id = issue.id AND _interest.member_id = ?", app.session.member.id } )
    :add_field("(_interest.member_id NOTNULL)", "is_interested")
    :left_join("delegating_interest_snapshot", "_delegating_interest", { "_delegating_interest.issue_id = issue.id AND _delegating_interest.member_id = ? AND _delegating_interest.event = issue.latest_snapshot_event", app.session.member.id } )
    :add_field("_delegating_interest.delegate_member_ids[1]", "is_interested_by_delegation_to_member_id")
    :add_field("_delegating_interest.delegate_member_ids[array_upper(_delegating_interest.delegate_member_ids, 1)]", "is_interested_via_member_id")
    :add_field("array_length(_delegating_interest.delegate_member_ids, 1)", "delegation_chain_length")
end

--local filters = execute.load_chunk{module="issue", chunk="_filters.lua", params = { member = app.session.member }}

--filters.content = function()
    
  ui.container{ attr = { class = "issues events" }, content = function()

    local last_event_date
    for i, event in ipairs(event_selector:exec()) do
      if event.occurrence.date ~= last_event_date then
        ui.container{ attr = { class = "date" }, content = format.date(event.occurrence.date) }
        last_event_date = event.occurrence.date
      end
      local class = "issue"
      if event.is_interested then
        class = class .. " interested"
      elseif event.is_interested_by_delegation_to_member_id then
        class = class .. " interested_by_delegation"
      end
      ui.container{ attr = { class = class }, content = function()

        ui.container { attr = { class = "issue_info" }, content = function()
        
          ui.container{ content = function()
            ui.link{
              attr = { class = "issue_id" },
              text = _("Issue ##{id}", { id = tostring(event.issue_id) }),
              module = "issue",
              view = "show",
              id = event.issue_id
            }

            slot.put(" &middot; ")
            ui.tag{ content = event.issue.area.name }
            slot.put(" &middot; ")
            ui.tag{ content = event.issue.area.unit.name }
            slot.put(" &middot; ")
            ui.tag{ content = event.issue.policy.name }
          end }

          ui.container{ attr = { class = "issue_policy_info" }, content = function()
            if event.member_id then
              ui.link{
                content = function()
                  execute.view{
                    module = "member_image",
                    view = "_show",
                    params = {
                      member = event.member,
                      image_type = "avatar",
                      show_dummy = true,
                      class = "micro_avatar",
                      popup_text = text
                    }
                  }
                end,
                module = "member", view = "show", id = event.member_id
              }
              slot.put(" ")
              ui.link{
                text = event.member.name,
                module = "member", view = "show", id = event.member_id
              }
              slot.put(" &middot; ") 
            end
            local event_name = event.event_name
            local event_image
            if event.event == "issue_state_changed" then
              if event.state == "discussion" then
                event_name = _"Discussion started"
                event_image = "message.png"
              elseif event.state == "verification" then
                event_name = _"Verification started"
                event_image = "lock.png"
              elseif event.state == "voting" then
                event_name = _"Voting started"
                event_image = "email_open.png"
              else
                event_name = event.state_name
              end
              if event_image then
                ui.image{ static = "icons/16/" .. event_image }
              end
            end
            ui.tag{ attr = { class = "event_name" }, content = event_name }
            slot.put(" &middot; ") 
            ui.tag{ attr = { class = "time" }, content = format.time(event.occurrence) }
          end }

        end }
        
        if event.suggestion_id then
          ui.container{ attr = { class = "suggestion" }, content = function()
            ui.link{
              text = event.suggestion.name,
              module = "suggestion", view = "show", id = event.suggestion_id
            }
          end }   
        end

        ui.container{ attr = { class = "initiative_list" }, content = function()
          if not event.initiative_id then
            local initiatives_selector = Initiative:new_selector()
              :add_where{ "initiative.issue_id = ?", event.issue_id }
              :add_order_by("initiative.rank, initiative.supporter_count")
            execute.view{ module = "initiative", view = "_list", params = { 
              issue = event.issue,
              initiatives_selector = initiatives_selector,
              no_sort = true,
              limit = 3
            } }
          else
          local initiatives_selector = Initiative:new_selector()
            :add_where{ "initiative.id = ?", event.initiative_id }
            execute.view{ module = "initiative", view = "_list", params = { 
              issue = event.issue,
              initiatives_selector = initiatives_selector,
              no_sort = true,
              limit = 1
            } }
          end
        end }

        --[[      
        if event.initiative_id then
          ui.container{ attr = { class = "initiative_id" }, content = event.initiative_id }
        end
        if event.draft_id then
          ui.container{ attr = { class = "draft_id" }, content = event.draft_id }
        end
        if event.suggestion_id then
          ui.container{ attr = { class = "suggestion_id" }, content = event.suggestion_id }
        end
  --]]
        
      end }
    end

  end }

--end
  
--filters.selector = event_selector
--ui.filters(filters)