local for_unit = param.get("for_unit", atom.boolean)
local for_area = param.get("for_area", atom.boolean)
local for_events = param.get("for_events", atom.boolean)
local for_member = param.get("for_member", "table")
local member = param.get("member", "table")
local phase = request.get_param{ name = "phase" }

local filters = {}

local admission_order_field = "filter_issue_order.order_in_unit"
if for_area then
  admission_order_field = "filter_issue_order.order_in_area"
end

local filter = { class = "filter_mode", name = "mode", label = _"mode" }

filter[#filter+1] = {
  name = "issue",
  label = _"issue list",
  selector_modifier = function() end
}

filter[#filter+1] = {
  name = "timeline",
  label = _"timeline",
  selector_modifier = function() end
}

--filters[#filters+1] = filter

if not for_issue and not for_member then

  -- units
  
  if not config.single_unit_id then
  
    local units
    if app.session.member then
      units = app.session.member:get_reference_selector("units"):add_order_by("name"):add_where("active"):exec()
    else
      units = Unit:new_selector():add_where("active"):add_order_by("name"):exec()
    end

    units:load_delegation_info_once_for_member_id(app.session.member_id)

    
    local filter = { class = "filter_unit", name = "unit", label = _"unit" }

    filter[#filter+1] = {
      name = "all",
      label = _"All units",
      selector_modifier = function(selector) 
        if app.session.member then
          selector:join("area", "__filter_area", "__filter_area.id = issue.area_id")
          selector:join("unit", "__filter_unit", "__filter_unit.id = __filter_area.unit_id AND __filter_unit.active")
          selector:join("privilege", "__filter_privilege", { "__filter_privilege.unit_id = __filter_area.unit_id AND __filter_privilege.member_id = ?", app.session.member_id })
        end
      end
    }

    for i, unit in ipairs(units) do
      filter[#filter+1] = {
        name = tostring(unit.id),
        label = unit.name,
        selector_modifier = function(selector)
          selector:join("area", "__filter_area", "__filter_area.id = issue.area_id")
          selector:add_where{ "__filter_area.unit_id = ?", unit.id }
        end
      }
      
    end

    filters[#filters+1] = filter

  end
  
  -- areas
  local selected_unit_id = config.single_unit_id or request.get_param{ name = "unit" }
  if selected_unit_id == "all" then
    selected_unit_id = nil 
  end
  local selected_unit = Unit:by_id(selected_unit_id)

  if not config.single_area_id and selected_unit then
  
    local filter = { class = "filter_unit", name = "area", label = _"area" }

    filter[#filter+1] = {
      name = "all",
      label = _"all subject areas",
      selector_modifier = function()  end
    }
    
    local areas = selected_unit.areas
    if config.area_reverse_order then
      areas = {}
      for i, area in ipairs(selected_unit.areas) do
        table.insert(areas, 1, area)
      end
    end

    for i, area in ipairs(areas) do
      if area.active then
        filter[#filter+1] = {
          name = tostring(area.id),
          label = area.name,
          selector_modifier = function(selector)
            if area.unit_id == selected_unit.id then
              selector:add_where{ "issue.area_id = ?", area.id }
            end
          end
        }
      end
    end
    
    filters[#filters+1] = filter
    
  end

  if app.session.member_id then
  
    -- interest
    
    local filter = { class = "filter_filter", name = "filter", label = _"interest" }

    filter[#filter+1] = {
      name = "all",
      label = _"all issues",
      selector_modifier = function()  end
    }

    if member and not for_unit and not for_area and not config.single_unit_id then
      filter[#filter+1] = {
        name = "my_units",
        label = _"in my units",
        selector_modifier = function ( selector )
          selector:join ( "area", "filter_area", "filter_area.id = issue.area_id" )
          selector:join ( "privilege", "filter_privilege", { 
            "filter_privilege.unit_id = filter_area.unit_id AND filter_privilege.member_id = ?", member.id
          })
        end
      }
    end
    
    if member then
      filter[#filter+1] = {
        name = "my_issues",
        label = _"my issues",
        selector_modifier = function ( selector )
          selector:left_join("interest", "filter_interest", { "filter_interest.issue_id = issue.id AND filter_interest.member_id = ? ", member.id })
          selector:left_join("direct_interest_snapshot", "filter_interest_s", { "filter_interest_s.issue_id = issue.id AND filter_interest_s.member_id = ? AND filter_interest_s.snapshot_id = issue.latest_snapshot_id", member.id })
          selector:left_join("delegating_interest_snapshot", "filter_d_interest_s", { "filter_d_interest_s.issue_id = issue.id AND filter_d_interest_s.member_id = ? AND filter_d_interest_s.snapshot_id = issue.latest_snapshot_id", member.id })
        end
      }
    end
    
    if not config.voting_only then
      filters[#filters+1] = filter
    end
    
    -- my issues

    if request.get_param{ name = "filter" } == "my_issues" then
      
      local delegation = request.get_param{ name = "delegation" }

      local filter = { class = "filter_interest subfilter", name = "interest", label = _"delegation" }
      
      filter[#filter+1] = {
        name = "all",
        label = _"interested directly or via delegation",
        selector_modifier = function ( selector ) 
          selector:add_where ( "filter_interest.issue_id NOTNULL OR filter_d_interest_s.issue_id NOTNULL" )
        end
      }

      filter[#filter+1] = {
        name = "direct",
        label = _"direct interest",
        selector_modifier = function ( selector )  
          selector:add_where ( "filter_interest.issue_id NOTNULL" )
        end
      }

      filter[#filter+1] = {
        name = "via_delegation",
        label = _"interest via delegation",
        selector_modifier = function ( selector )  
          selector:add_where ( "filter_d_interest_s.issue_id NOTNULL" )
        end
      }

      filter[#filter+1] = {
        name = "initiated",
        label = _"initiated by me",
        selector_modifier = function ( selector )  
          selector:add_where ( "filter_interest.issue_id NOTNULL" )
        end
      }
      
      filters[#filters+1] = filter

    end
  
  end
  
  -- phase
  
  local filter = { name = "phase", label = _"phase" }
  
  filter[#filter+1] = {
    name = "all",
    label = _"in all phases",
    selector_modifier = function ( selector )
      if not for_events then
        selector:left_join ( "issue_order_in_admission_state", "filter_issue_order",    "filter_issue_order.id = issue.id" )
        selector:add_order_by ( "issue.closed DESC NULLS FIRST" )
        selector:add_order_by ( "issue.accepted ISNULL" )
        selector:add_order_by ( "CASE WHEN issue.accepted ISNULL THEN NULL ELSE justify_interval(coalesce(issue.fully_frozen + issue.voting_time, issue.half_frozen + issue.verification_time, issue.accepted + issue.discussion_time, issue.created + issue.max_admission_time) - now()) END" )
        selector:add_order_by ( "CASE WHEN issue.accepted ISNULL THEN " .. admission_order_field .. " ELSE NULL END" )
        selector:add_order_by ( "id" )
      end
    end
  }

  filter[#filter+1] = {
    name = "admission",
    label = _"Admission",
    selector_modifier = function ( selector )
      selector:add_where { "issue.state = ?", "admission" }
      if not for_events then
        selector:left_join ( "issue_order_in_admission_state", "filter_issue_order", "filter_issue_order.id = issue.id" )
        selector:add_order_by ( admission_order_field )
        selector:add_order_by ( "id" )
      end
    end
  }

  filter[#filter+1] = {
    name = "discussion",
    label = _"Discussion",
    selector_modifier = function ( selector )
      selector:add_where { "issue.state = ?", "discussion" }
      if not for_events then
        selector:add_order_by ( "issue.accepted + issue.discussion_time - now()" )
        selector:add_order_by ( "id" )
      end
    end
  }

  filter[#filter+1] = {
    name = "verification",
    label = _"Verification",
    selector_modifier = function ( selector )
      selector:add_where { "issue.state = ?", "verification" }
      if not for_events then
        selector:add_order_by ( "issue.half_frozen + issue.verification_time - now()" )
        selector:add_order_by ( "id" )
      end
    end
  }

  filter[#filter+1] = {
    name = "voting",
    label = _"Voting",
    selector_modifier = function ( selector )
      selector:add_where { "issue.state = ?", "voting" }
      if not for_events then
        selector:add_order_by ( "issue.fully_frozen + issue.voting_time - now()" )
        selector:add_order_by ( "id" )
      end
    end
  }

  filter[#filter+1] = {
    name = "closed",
    label = _"Results",
    selector_modifier = function ( selector )
      if not for_events then
        selector:add_where ( "issue.closed NOTNULL" )
        selector:add_order_by ( "issue.closed DESC" )
        selector:add_order_by ( "id" )
      end
    end
  }

  -- TODO
  if not config.voting_only then
    filters[#filters+1] = filter
  end
  
  -- voting

  if phase == "voting" and member then
  
    local filter = { class = "subfilter", name = "voted", label = _"voted" }
    
    filter[#filter+1] = {
      name = "all",
      label = _"voted and not voted by me",
      selector_modifier = function(selector)  end
    }

    filter[#filter+1] = {
      name = "voted",
      label = _"voted by me",
      selector_modifier = function(selector) 
        selector:join("direct_voter", "filter_direct_voter", { "filter_direct_voter.issue_id = issue.id AND filter_direct_voter.member_id = ?", member.id })
      end
    }

    filter[#filter+1] = {
      name = "not_voted",
      label = _"not voted by me",
      selector_modifier = function(selector)
        selector:left_join("direct_voter", "filter_direct_voter", { "filter_direct_voter.issue_id = issue.id AND filter_direct_voter.member_id = ?", member.id })
        selector:add_where("filter_direct_voter.issue_id ISNULL")
      end
    }
    filters[#filters+1] = filter
    
    
  end
  
  -- closed

  if phase == "closed" then
  
    local filter = { class = "subfilter", name = "closed", label = _"closed" }
    
    filter[#filter+1] = {
      name = "all",
      label = _"all results",
      selector_modifier = function ( selector ) end
    }

    filter[#filter+1] = {
      name = "finished",
      label = _"finished",
      selector_modifier = function ( selector )
        selector:add_where ( "issue.state::text like 'finished_%'" )
      end
    }

    filter[#filter+1] = {
      name = "canceled",
      label = _"canceled",
      selector_modifier = function ( selector )  
        selector:add_where ( "issue.closed NOTNULL AND NOT issue.state::text like 'finished_%' AND issue.accepted NOTNULL" )
      end
    }

    filter[#filter+1] = {
      name = "not_accepted",
      label = _"not admitted",
      selector_modifier = function ( selector )  
        selector:add_where ( "issue.closed NOTNULL AND issue.accepted ISNULL" )
      end
    }

    if member then
      filter[#filter+1] = {
        name = "voted",
        label = _"voted by me",
        selector_modifier = function(selector)
          selector:left_join("direct_voter", "filter_direct_voter", { "filter_direct_voter.issue_id = issue.id AND filter_direct_voter.member_id = ?", member.id })
          selector:left_join("delegating_voter", "filter_delegating_voter", { "filter_delegating_voter.issue_id = issue.id AND filter_delegating_voter.member_id = ?", member.id })
          selector:add_where("filter_direct_voter.issue_id NOTNULL or filter_delegating_voter.issue_id NOTNULL")
        end
      }

      filter[#filter+1] = {
        name = "voted_direct",
        label = _"voted directly by me",
        selector_modifier = function(selector)
          selector:join("direct_voter", "filter_direct_voter", { "filter_direct_voter.issue_id = issue.id AND filter_direct_voter.member_id = ?", member.id })
        end
      }

      filter[#filter+1] = {
        name = "voted_via_delegation",
        label = _"voted via delegation",
        selector_modifier = function(selector)
          selector:join("delegating_voter", "filter_delegating_voter", { "filter_delegating_voter.issue_id = issue.id AND filter_delegating_voter.member_id = ?", member.id })
        end
      }

      filter[#filter+1] = {
        name = "not_voted",
        label = _"not voted by me",
        selector_modifier = function(selector)
          selector:left_join("direct_voter", "filter_direct_voter", { "filter_direct_voter.issue_id = issue.id AND filter_direct_voter.member_id = ?", member.id })
          selector:left_join("delegating_voter", "filter_delegating_voter", { "filter_delegating_voter.issue_id = issue.id AND filter_delegating_voter.member_id = ?", member.id })
          selector:add_where("filter_direct_voter.issue_id ISNULL AND filter_delegating_voter.issue_id ISNULL")
        end
      }
    end
    
    filters[#filters+1] = filter
    
    
  end

  
end


return filters
