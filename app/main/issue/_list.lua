local for_member = param.get ( "for_member", "table" )
local for_unit =   param.get ( "for_unit",   "table" )
local for_area =   param.get ( "for_area",   "table" )
local for_issue =  param.get ( "for_issue",  "table" )
local for_initiative =  param.get ( "for_initiative",  "table" )
local for_sidebar = param.get("for_sidebar", atom.boolean)
local no_filter =  param.get ( "no_filter",  atom.boolean )
local search =     param.get ( "search" )

local limit = 25

local mode = request.get_param{ name = "mode" } or "issue"

if for_initiative or for_issue or for_member then
  mode = "timeline"
end

if config.single_unit_id then
  for_unit = Unit:by_id(config.single_unit_id)
end

local selector

if search then

  selector = Issue:get_search_selector(search)

  
elseif mode == "timeline" then

  local event_max_id = request.get_param_strings()["event_max_id"]

  selector = Event:new_selector()
    :add_order_by("event.id DESC")
    :join("issue", nil, "issue.id = event.issue_id")
    :add_field("now() - event.occurrence", "time_ago")
    :limit(limit + 1)
    
  if event_max_id then
    selector:add_where{ "event.id < ?", event_max_id }
  end

  if for_member then
    selector:add_where{ "event.member_id = ?", for_member.id }
  end

  if for_initiative then
    selector:add_where{ "event.initiative_id = ?", for_initiative.id }
  end

  
elseif mode == "issue" then
  
  selector = Issue:new_selector()

end

if for_unit then
  selector:join("area", nil, "area.id = issue.area_id")
  selector:add_where{ "area.unit_id = ?", for_unit.id }
elseif for_area then
  selector:add_where{ "issue.area_id = ?", for_area.id }
elseif for_issue then
  selector:add_where{ "issue.id = ?", for_issue.id }
end
  
if not search and app.session.member_id then
  selector
    :left_join("interest", "_interest", { 
      "_interest.issue_id = issue.id AND _interest.member_id = ?", app.session.member.id 
    } )
    :add_field("(_interest.member_id NOTNULL)", "is_interested")
    :left_join("delegating_interest_snapshot", "_delegating_interest", { [[
      _delegating_interest.issue_id = issue.id AND 
      _delegating_interest.member_id = ? AND
      _delegating_interest.snapshot_id = issue.latest_snapshot_id
    ]], app.session.member.id } )
    :add_field("_delegating_interest.delegate_member_ids[1]", "is_interested_by_delegation_to_member_id")
    :add_field("_delegating_interest.delegate_member_ids[array_upper(_delegating_interest.delegate_member_ids, 1)]", "is_interested_via_member_id")    
    :add_field("array_length(_delegating_interest.delegate_member_ids, 1)", "delegation_chain_length")
end

local function doit()

  local last_event_id

  local items = selector:exec()

  local row_class = "sectionRow"
  if for_sidebar then
    row_class = "sidebarRow"
  end
  
  if mode == "timeline" then
    local issues = items:load ( "issue" )
    local initiative = items:load ( "initiative" )
    items:load ( "suggestion" )
    items:load ( "member" )
    issues:load_everything_for_member_id ( app.session.member_id )
    initiative:load_everything_for_member_id ( app.session.member_id )
  elseif mode == "issue" then
    items:load_everything_for_member_id ( app.session.member_id )
  end

  local last_event_date
  for i, item in ipairs(items) do
    local event
    local issue
    if mode == "timeline" then
      event = item
      issue = item.issue
    elseif mode == "issue" then
      event = {}
      issue = item
    end
    
    last_event_id = event.id

    local class = "mdl-card mdl-shadow--2dp mdl-card__fullwidth event " .. row_class
    if event.suggestion_id then
      class = class .. " suggestion"
    end
    
    ui.container{ attr = { class = class, id = "issue_" .. issue.id }, content = function()
      local event_name
      local event_icon
      local negative_event = false
      
      local days_ago_text

      if mode == "timeline" then
        event_name = event.event_name
          if event.event == "issue_state_changed" then
            if event.state == "discussion" then
              event_name = _"Discussion started"
            elseif event.state == "verification" then
              event_name = _"Verification started"
            elseif event.state == "voting" then
              event_name = _"Voting started"
            elseif event.state == "finished_with_winner" then
              event_name = event.state_name
            elseif event.state == "finished_without_winner" then
              event_name = event.state_name
              negative_event = true
            else
              event_name = event.state_name
              negative_event = true
            end
          elseif event.event == "initiative_revoked" then
            negative_event = true
          end

        if event.time_ago == 0 then
          days_ago_text = _("today at #{time}", { time = format.time(event.occurrence) })
        elseif event.time_ago == 1 then
          days_ago_text = _("yesterday at #{time}", { time = format.time(event.occurrence) })
        else
          days_ago_text = _("#{interval} ago", { interval = format.interval_text ( event.time_ago ) } )
        end
        
      elseif mode == "issue" then
        local event_icons_map = {
          admission = "bubble_chart",
          discussion = "question_answer",
          verification = "find_in_page",
          voting = "mail",
          finished_with_winner = "emoji_events",
          finished_without_winner = "do_not_disturb",
          canceled = "clear"
        }
        event_icon = event_icons_map[issue.state] or event_icons_map["canceled"]
        event_name = issue.state_name
        if issue.state_time_left:sub(1,1) ~= "-" then
          days_ago_text = _( "#{interval_text} left", {
            interval_text = format.interval_text ( issue.state_time_left )
          })
        elseif issue.closed then
          days_ago_text = _( "#{interval_text} ago", {
            interval_text = format.interval_text ( issue.closed_ago )
          })
        else
          days_ago_text = _"phase ends soon" 
        end
        if issue.closed and not issue.fully_frozen then
          negative_event = true
        end
        if issue.state == "finished_without_winner" 
            or issue.state == "canceled_no_initiative_admitted"
            or issue.state == "canceled_by_admin"
        then
          negative_event = true
        end
      end

      local class= "event_info"
      
      if negative_event then
        class = class .. " negative"
      end

      if not for_issue and not for_initiative then
        ui.container{ attr = { class = "mdl-card__title mdl-card--has-fab mdl-card--border card-issue" }, content = function()
          ui.container{ attr = { class = "contextlinks" }, content = function()
            if not (config.single_unit_id and config.single_area_id) then
              if not config.single_unit_id then
                ui.icon("group")
                slot.put(" ")
                ui.link{
                  module = "index", view = "index", params = { unit = issue.area.unit_id },
                  attr = { class = "unit" }, content = issue.area.unit.name                 }
              end
              if not config.single_area_id then
                if not config.single_unit_id then
                  slot.put(" &nbsp;&nbsp;&nbsp; ")
                end
                ui.icon("category")
                slot.put(" ")
                ui.link{
                  module = "index", view = "index", params = { unit = issue.area.unit_id, area = issue.area_id },
                  attr = { class = "area" }, content = issue.area.name
                }
              end
            end
            slot.put(" &nbsp;&nbsp;&nbsp; ")
            ui.icon("gavel")
            slot.put(" ")
            ui.link{
              module = "issue", view = "show", id = issue.id,
              attr = { class = "issue" }, content = issue.name
            }
--          end }
--          ui.container{ attr = { class = "mdl-card__subtitle-text .mdl-cell--hide-phone" }, content = function()
            ui.container{ attr = { class = class, style = "float: right; color: #fff;" }, content = function ()
              if event_icon then
                ui.tag{ tag = "i", attr = { class = "material-icons", ["aria-hidden"] = "true" }, content = event_icon }
              end
              slot.put(" ")
              ui.tag { content = event_name }
              slot.put(" ")
              ui.tag{ content = "(" .. days_ago_text .. ")" }
            end }
          end }
          if app.session.member and issue.fully_frozen and not issue.closed and not issue.member_info.direct_voted and app.session.member:has_voting_right_for_unit_id(issue.area.unit_id) then
            ui.link {
              attr = { class = "mdl-button mdl-js-button mdl-button--fab mdl-button--colored" ,
                style = "position: absolute; right: 20px; bottom: -27px;"
              },
              module = "vote", view = "list", 
              params = { issue_id = issue.id },
              content = function()
                ui.tag{ tag = "i", attr = { class = "material-icons" }, content = config.voting_icon or "mail_outline" }
              end 
            }
          end
        end }
      end

      if event.suggestion_id then
        ui.container{ attr = { class = "suggestion" }, content = function()
          ui.link{
            text = format.string(event.suggestion.name, {
              truncate_at = 160, truncate_suffix = true
            }),
            module = "initiative", view = "show", id = event.initiative.id,
            params = { suggestion_id = event.suggestion_id },
            anchor = "s" .. event.suggestion_id
          }
        end }
      end

      if not for_initiative and (not for_issue or event.initiative_id) then
        
        ui.container{ attr = { class = "initiative_list" }, content = function()
          if event.initiative_id then
            local initiative = event.initiative
              
            execute.view{ module = "initiative", view = "_list", params = { 
              issue = issue,
              initiative = initiative,
              for_event = mode == "timeline" and not (event.state == issue.state)

            } }
          else
            local initiatives = issue.initiatives
            execute.view{ module = "initiative", view = "_list", params = { 
              issue = issue,
              initiatives = initiatives,
              for_event = mode == "timeline" and not (event.state == issue.state)
            } }
          end
        end }
      end
      if 
        app.session.member_id and (
          (not issue.fully_frozen and app.session.member:has_initiative_right_for_unit_id(issue.area.unit_id))
          or (issue.fully_frozen and app.session.member:has_voting_right_for_unit_id(issue.area.unit_id))
        )
      then
        ui.container{ attr = { class = "mdl-card__actions mdl-card--border" }, content = function()
          execute.view{ 
            module = "delegation", view = "_info", params = { 
              issue = issue, member = for_member 
            }
          }
        end }
      end
    end }

  end
  
  if mode == "timeline" then
    if for_sidebar then
      ui.container { attr = { class = row_class }, content = function ()
        ui.link{
          attr = { class = "moreLink" },
          text = _"Show full history",
          module = "initiative", view = "history", id = for_initiative.id
        }
      end }
    elseif #items > limit then
      ui.container { attr = { class = row_class }, content = function ()
        local params = request.get_param_strings()
        ui.link{
          attr = { class = "moreLink" },
          text = _"Show older events",
          module = request.get_module(),
          view = request.get_view(),
          id = for_unit and for_unit.id or for_area and for_area.id or for_issue and for_issue.id or for_member and for_member.id,
          params = {
            mode = "timeline",
            event_max_id = last_event_id,
            tab = params["tab"],
            phase = params["phase"],
            closed = params["closed"]
          }
        }
      end }
    elseif #items < 1 then
      ui.container { attr = { class = row_class }, content = _"No more events available" }
    end
  end
  
  if #items < 1 then
    ui.section( function()
      ui.sectionRow( function()
        ui.container{ content = _"No results for this selection" }
      end )
    end )
  end
  
  
end


local filters = {}

if not for_initiative and not for_issue and not no_filter then
  
  filters = execute.chunk{
    module = "issue", chunk = "_filters", params = {
    for_events = mode == "timeline" and true or false,
    member = app.session.member, 
    for_member = for_member, 
    state = for_state, 
    for_unit = for_unit and true or false, 
    for_area = for_area and true or false
  }}
end

filters.opened = true
filters.selector = selector


local function dotabs()
  slot.select("filter", function()
    ui.container{ attr = { class = "mdl-tabs mdl-js-tabs mdl-js-ripple-effect float-left" }, content = function()
      ui.container{ attr = { class = "mdl-tabs__tab-bar" }, content = function()
        local mode = request.get_param{ name = "mode" }
        local css_active = (not mode or mode == "issue") and " is-active" or ""
        ui.link{ module = request.get_module(), view = request.get_view(), id = request.get_id_string(), content = "Issues", attr = { class = "mdl-tabs__tab" .. css_active } }
        local css_active = mode and " is-active" or " "
        ui.link{ module = request.get_module(), view = request.get_view(), id = request.get_id_string(), params = { mode = "timeline" }, content = "Timeline", attr = { class = "mdl-tabs__tab" .. css_active } }
        ui.link{ module = "member", view = "list", content = "Member", attr = { class = "mdl-tabs__tab" } }
      end }
    end }
  end)
end


if mode == "timeline" then
  --dotabs()
  filters.content = function()
    doit()
  end
else
  -- dotabs()
  filters.content = function()
    if config.voting_only then
      local admission_order_field = "filter_issue_order.order_in_unit"
      if for_area then
        admission_order_field = "filter_issue_order.order_in_area"
      end
      selector:left_join ( "issue_order_in_admission_state", "filter_issue_order",    "filter_issue_order.id = issue.id" )
      selector:add_order_by ( "issue.closed DESC NULLS FIRST" )
      selector:add_order_by ( "issue.accepted ISNULL" )
      selector:add_order_by ( "CASE WHEN issue.accepted ISNULL THEN NULL ELSE justify_interval(coalesce(issue.fully_frozen + issue.voting_time, issue.half_frozen + issue.verification_time, issue.accepted + issue.discussion_time, issue.created + issue.max_admission_time) - now()) END" )
      selector:add_order_by ( "CASE WHEN issue.accepted ISNULL THEN " .. admission_order_field .. " ELSE NULL END" )
      selector:add_order_by ( "id" )
    end
    if not search then
--      execute.view{ module = "index", view = "_head" }
    end
    ui.paginate{
      selector = selector,
      per_page = 25,
      content = doit
    }
  end
end

filters.class = "mdl-special-card mdl-card__fullwidth mdl-shadow--2dp"

filters.legend = _"Filter issues:"

ui.filters(filters)


      
