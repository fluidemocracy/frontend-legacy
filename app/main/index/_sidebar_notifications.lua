local notification_links = {}

if app.session.member.notify_email_unconfirmed then
  notification_links[#notification_links+1] = {
    module = "index", view = "email_unconfirmed",
    text = _"Confirm your email address"
  }
end

local agents = Agent:new_selector()
  :add_where{ "controller_id = ?", app.session.member_id }
  :add_where{ "accepted ISNULL" }
  :exec()
for i, agent in ipairs(agents) do
  local member = Member:by_id(agent.controlled_id)
  notification_links[#notification_links+1] = {
    module = "agent", view = "show", params = { controlled_id = agent.controlled_id },
    text = _("Account access invitation from '#{member_name}'", { member_name = member.name })
  }
end

if config.check_delegations_interval_soft then
  local member = Member:new_selector()
    :add_where({ "id = ?", app.session.member_id })
    :add_field({ "now() > COALESCE(last_delegation_check, activated) + ?::interval", config.check_delegations_interval_soft }, "needs_delegation_check_soft")
    :single_object_mode()
    :exec()
    

  if member.needs_delegation_check_soft then

    local delegations = Delegation:delegations_to_check_for_member_id(member.id)
    
    if #delegations > 0 then
      notification_links[#notification_links+1] = {
        module = "index", view = "check_delegations", 
        text = _"Check your outgoing delegations"
      }
    end
    
  end
end

local broken_delegations = Delegation:selector_for_broken(app.session.member_id):exec()

for i, delegation in ipairs(broken_delegations) do
  local scope
  local context
  local id
  if delegation.scope == "unit" then
    scope = _"unit"
    id = delegation.unit_id
    context = delegation.unit.name
  elseif delegation.scope == "area" then
    scope = _"area"
    id = delegation.area_id
    context = delegation.area.name
  elseif delegation.scope == "issue" then
    scope = _"issue"
    id = delegation.issue_id
    context = delegation.issue.name
  end
   
  notification_links[#notification_links+1] = {
    module = delegation.scope, view = "show", id = id,
    text = _("Check your #{scope} delegation to '#{trustee_name}' for '#{context}'", {
      trustee_name = delegation.trustee.name,
      scope = scope,
      context = context
    })
  }
end

local selector = Issue:new_selector()
  :join("area", nil, "area.id = issue.area_id")
  :join("privilege", nil, { "privilege.unit_id = area.unit_id AND privilege.member_id = ? AND privilege.voting_right", app.session.member_id })
  :left_join("direct_voter", nil, { "direct_voter.issue_id = issue.id AND direct_voter.member_id = ?", app.session.member.id })
  :left_join("non_voter", nil, { "non_voter.issue_id = issue.id AND non_voter.member_id = ?", app.session.member.id })
  :left_join("interest", nil, { "interest.issue_id = issue.id AND interest.member_id = ?", app.session.member.id })
  :add_where{ "direct_voter.member_id ISNULL" }
  :add_where{ "non_voter.member_id ISNULL" }
  :add_where{ "interest.member_id NOTNULL" }
  :add_where{ "issue.fully_frozen NOTNULL" }
  :add_where{ "issue.closed ISNULL" }
  :add_order_by{ "issue.fully_frozen + issue.voting_time ASC" }
  
local issues_to_vote = selector:exec()

for i, issue in ipairs(issues_to_vote) do
  notification_links[#notification_links+1] = {
    module = "issue", view = "show", id = issue.id,
    text = _("#{issue} is in voting", { issue = issue.name })
  }
end

local initiator_invites = Initiator:selector_for_invites(app.session.member_id):exec()
  
for i, initiative in ipairs(initiator_invites) do
  notification_links[#notification_links+1] = {
    module = "initiative", view = "show", id = initiative.id,
    text = _("You are invited to become initiator of '#{initiative_name}'", { initiative_name = initiative.display_name })
  }
end

local updated_drafts = Initiative:selector_for_updated_drafts(app.session.member_id):exec()

for i, initiative in ipairs(updated_drafts) do
  notification_links[#notification_links+1] = {
    module = "initiative", view = "show", id = initiative.id,
    text = _("New draft for initiative '#{initiative_name}'", { initiative_name = initiative.display_name })
  }
end

if #notification_links > 0 then
  ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
    ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
      ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Notifications" }
    end }
    ui.container{ attr = { class = "mdl-card__content what-can-i-do-here" }, content = function()
      ui.tag{ tag = "ul", attr = { class = "ul" }, content = function()
        for i, notification_link in ipairs(notification_links) do
          ui.tag{ tag = "li", content = function()
            ui.link(notification_link)
          end }
        end
      end }
    end }
  end }
end
