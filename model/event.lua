Event = mondelefant.new_class()
Event.table = 'event'

Event:add_reference{
  mode          = 'm1',
  to            = "Unit",
  this_key      = 'unit_id',
  that_key      = 'id',
  ref           = 'unit',
}

Event:add_reference{
  mode          = 'm1',
  to            = "Area",
  this_key      = 'area_id',
  that_key      = 'id',
  ref           = 'area',
}

Event:add_reference{
  mode          = 'm1',
  to            = "Policy",
  this_key      = 'policy_id',
  that_key      = 'id',
  ref           = 'policy',
}

Event:add_reference{
  mode          = 'm1',
  to            = "Issue",
  this_key      = 'issue_id',
  that_key      = 'id',
  ref           = 'issue',
}

Event:add_reference{
  mode          = 'm1',
  to            = "Initiative",
  this_key      = 'initiative_id',
  that_key      = 'id',
  ref           = 'initiative',
}

Event:add_reference{
  mode          = 'm1',
  to            = "Suggestion",
  this_key      = 'suggestion_id',
  that_key      = 'id',
  ref           = 'suggestion',
}

Event:add_reference{
  mode          = 'm1',
  to            = "Member",
  this_key      = 'member_id',
  that_key      = 'id',
  ref           = 'member',
}

function Event:by_member_id(member_id)
  return Event:new_selector()
    :add_where{ "member_id = ?", member_id }
    :add_order_by("id DESC")
    :exec()
end

function Event.object_get:event_name()
  return ({
    issue_state_changed = _"Issue reached next phase",
    initiative_created_in_new_issue = _"New issue",
    initiative_created_in_existing_issue = _"New initiative",
    initiative_revoked = _"Initiative revoked",
    new_draft_created = _"New initiative draft",
    suggestion_created = _"New suggestion"
  })[self.event]
end
  
function Event.object_get:state_name()
  return Issue:get_state_name_for_state(self.state)
end
  
function Event.object:send_notification()
  
  local members_to_notify = Member:new_selector()
    :join("member_to_notify", nil, "member_to_notify.id = member.id")
    :join("event_for_notification", nil, { "event_for_notification.recipient_id = member.id AND event_for_notification.id = ?", self.id } )
    -- SAFETY FIRST, NEVER send notifications for events more then 3 days in past or future
    :add_where("now() - event_for_notification.occurrence BETWEEN '-3 days'::interval AND '3 days'::interval")
    -- do not notify a member about the events caused by the member
    :add_where("event_for_notification.member_id ISNULL OR event_for_notification.member_id != member.id")
    :add_where("member.notify_email NOTNULL")
    :exec()
    
  io.stderr:write("Sending notifications for event " .. self.id .. " to " .. (#members_to_notify) .. " members\n")

  for i, member in ipairs(members_to_notify) do
    local subject
    local body = ""
    
    locale.do_with(
      { lang = member.lang or config.default_lang },
      function()

        body = body .. _("[event mail]      Unit: #{name}", { name = self.issue.area.unit.name }) .. "\n"
        body = body .. _("[event mail]      Area: #{name}", { name = self.issue.area.name }) .. "\n"
        body = body .. _("[event mail]     Issue: ##{id}", { id = self.issue_id }) .. "\n\n"
        body = body .. _("[event mail]    Policy: #{policy}", { policy = self.issue.policy.name }) .. "\n\n"
        body = body .. _("[event mail]     Phase: #{phase}", { phase = self.state_name }) .. "\n\n"

        local url

        if self.initiative_id then
          url = request.get_absolute_baseurl() .. "initiative/show/" .. self.initiative_id .. ".html"
        else
          url = request.get_absolute_baseurl() .. "issue/show/" .. self.issue_id .. ".html"
        end
        
        body = body .. _("[event mail]       URL: #{url}", { url = url }) .. "\n\n"
        
        local leading_initiative
        
        if self.initiative_id then
          local initiative = Initiative:by_id(self.initiative_id)
          body = body .. _("i#{id}: #{name}", { id = initiative.id, name = initiative.name }) .. "\n\n"
        else
          local initiative_count = Initiative:new_selector()
            :add_where{ "initiative.issue_id = ?", self.issue_id }
            :count()
          local initiatives = Initiative:new_selector()
            :add_where{ "initiative.issue_id = ?", self.issue_id }
            :add_order_by("initiative.admitted DESC NULLS LAST, initiative.rank NULLS LAST, initiative.harmonic_weight DESC NULLS LAST, id")
            :limit(3)
            :exec()
          for i, initiative in ipairs(initiatives) do
            if i == 1 then
              leading_initiative = initiative
            end
            body = body .. _("i#{id}: #{name}", { id = initiative.id, name = initiative.name }) .. "\n"
          end
          if initiative_count - 3 > 0 then
            body = body .. _("and #{count} more initiatives", { count = initiative_count - 3 }) .. "\n"
          end
          body = body .. "\n"
        end
        
        subject = config.mail_subject_prefix
        
        if self.event == "issue_state_changed" then
          subject = subject .. _("State of #{issue} changed to #{state} / #{initiative}", { issue = self.issue.name, state = Issue:get_state_name_for_state(self.state), initiative = leading_initiative.display_name })
        elseif self.event == "initiative_revoked" then
          subject = subject .. _("Initiative revoked: #{initiative_name}", { initiative_name = self.initiative.display_name })
        end
      
        local success = net.send_mail{
          envelope_from = config.mail_envelope_from,
          from          = config.mail_from,
          reply_to      = config.mail_reply_to,
          to            = { name = member.name, address = member.notify_email },
          subject       = subject,
          content_type  = "text/plain; charset=UTF-8",
          content       = body
        }
    
      end
    )
  end
  
end

function Event:get_events_after_id(id)
  return (
    Event:new_selector()
      :add_where{ "event.id > ?", id }
      :add_order_by("event.id")
      :exec()
  )
end
      


Event.handlers = {}

function Event:add_handler(func)
  table.insert(Event.handlers, func)
end

function Event:process_stream(poll)

  db:query('LISTEN "event"')

  local last_event_id = EventProcessed:get_last_id()
  
  while true do
    
    local events = Event:get_events_after_id(last_event_id)
    
    for i_event, event in ipairs(events) do
      last_event_id = event.id
      EventProcessed:set_last_id(last_event_id)
      for i_handler, event_handler in ipairs(Event.handlers) do
        event_handler(event)
      end
      event:send_notification()
    end

    if poll then
      while not db:wait(0) do
        if not poll({[db.fd]=true}, nil, nil, true) then
          goto exit
        end
      end
    else
      db:wait()
    end
    while db:wait(0) do end  -- discard multiple events
    
  end

  ::exit::

  db:query('UNLISTEN "event"')

end
