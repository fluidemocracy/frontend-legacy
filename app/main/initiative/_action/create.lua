local issue
local area

local issue_id = param.get("issue_id", atom.integer)
if issue_id then
  issue = Issue:new_selector():add_where{"id=?",issue_id}:for_share():single_object_mode():exec()
  if issue.closed then
    slot.put_into("error", _"This issue is already closed.")
    return false
  elseif issue.fully_frozen then 
    slot.put_into("error", _"Voting for this issue has already begun.")
    return false
  elseif issue.phase_finished then
    slot.put_into("error", _"Current phase is already closed.")
    return false
  end
  area = issue.area
else
  local area_id = param.get("area_id", atom.integer)
  area = Area:new_selector():add_where{"id=?",area_id}:single_object_mode():exec()
  if not area.active then
    slot.put_into("error", "Invalid area.")
    return false
  end
end

if not app.session.member:has_voting_right_for_unit_id(area.unit_id) then
  return execute.view { module = "index", view = "403" }
end

local policy_id = param.get("policy_id", atom.integer)
local policy
if policy_id then
  policy = Policy:by_id(policy_id)
end

if not issue then
  if policy_id == -1 then
    slot.put_into("error", _"Please choose a policy")
    return false
  end
  if not policy.active then
    slot.put_into("error", "Invalid policy.")
    return false
  end
  if policy.polling and not app.session.member:has_polling_right_for_unit_id(area.unit_id) then
    return execute.view { module = "index", view = "403" }
  end
  if not area:get_reference_selector("allowed_policies")
    :add_where{ "policy.id = ?", policy_id }
    :optional_object_mode()
    :exec()
  then
    slot.put_into("error", "policy not allowed")
    return false
  end
end

local is_polling = (issue and param.get("polling", atom.boolean)) or (policy and policy.polling) or false

local tmp = db:query({ "SELECT text_entries_left, initiatives_left FROM member_contingent_left WHERE member_id = ? AND polling = ?", app.session.member.id, is_polling }, "opt_object")
if not tmp or tmp.initiatives_left < 1 then
  slot.put_into("error", _"Sorry, your contingent for creating initiatives has been used up. Please try again later.")
  return false
end
if tmp and tmp.text_entries_left < 1 then
  slot.put_into("error", _"Sorry, you have reached your personal flood limit. Please be slower...")
  return false
end

local name = param.get("name")

local name = util.trim(name)

if #name < 3 then
  slot.put_into("error", _"Please enter a meaningful title for your initiative!")
  return false
end

if #name > 140 then
  slot.put_into("error", _"This title is too long!")
  return false
end

local timing
if not issue and policy.free_timeable then
  local free_timing_string = util.trim(param.get("free_timing"))
  if not free_timing_string or #free_timing_string < 1 then
    slot.put_into("error", _"Choose timing")
    return false
  end
  local available_timings
  if config.free_timing and config.free_timing.available_func then
    available_timings = config.free_timing.available_func(policy)
    if available_timings == false then
      slot.put_into("error", "error in free timing config")
      return false
    end
  end
  if available_timings then
    local timing_available = false
    for i, available_timing in ipairs(available_timings) do
      if available_timing.id == free_timing_string then
	timing_available = true
      end
    end
    if not timing_available then
      slot.put_into("error", _"Invalid timing")
      return false
    end
  end
  timing = config.free_timing.calculate_func(policy, free_timing_string)
  if not timing then
    slot.put_into("error", "error in free timing config")
    return false
  end
end

local draft_text = param.get("draft")

if not draft_text then
  return false
end

local draft_text = util.wysihtml_preproc(draft_text)

local valid_html, error_message = util.html_is_safe(draft_text)
if not valid_html then
  slot.put_into("error", _("Draft contains invalid formatting or character sequence: #{error_message}", { error_message = error_message }) )
  return false
end

if config.initiative_abstract then
  local abstract = param.get("abstract")
  if not abstract then
    return false
  end
  abstract = encode.html(abstract)
  draft_text = abstract .. "<!--END_OF_ABSTRACT-->" .. draft_text
end

local location = param.get("location")
if location == "" then
  location = nil
end

if param.get("preview") or param.get("edit") then
  return
end

local initiative = Initiative:new()

if not issue then
  issue = Issue:new()
  issue.area_id = area.id
  issue.policy_id = policy_id
  
  if policy.polling then
    issue.accepted = 'now'
    issue.state = 'discussion'
    initiative.polling = true
    
    if policy.free_timeable then
      issue.discussion_time = timing.discussion
      issue.verification_time = timing.verification
      issue.voting_time = timing.voting
    end
    
  end
  
  issue:save()

  if config.etherpad then
    local result = net.curl(
      config.etherpad.api_base 
      .. "api/1/createGroupPad?apikey=" .. config.etherpad.api_key
      .. "&groupID=" .. config.etherpad.group_id
      .. "&padName=Issue" .. tostring(issue.id)
      .. "&text=" .. request.get_absolute_baseurl() .. "issue/show/" .. tostring(issue.id) .. ".html"
    )
  end
end

if param.get("polling", atom.boolean) and app.session.member:has_polling_right_for_unit_id(area.unit_id) then
  initiative.polling = true
end
initiative.issue_id = issue.id
initiative.name = name
initiative:save()

local draft = Draft:new()
draft.initiative_id = initiative.id
draft.formatting_engine = formatting_engine
draft.content = draft_text
draft.location = location
draft.author_id = app.session.member.id
draft:save()

local initiator = Initiator:new()
initiator.initiative_id = initiative.id
initiator.member_id = app.session.member.id
initiator.accepted = true
initiator:save()

if not is_polling then
  local supporter = Supporter:new()
  supporter.initiative_id = initiative.id
  supporter.member_id = app.session.member.id
  supporter.draft_id = draft.id
  supporter:save()
end

slot.put_into("notice", _"Initiative successfully created")

request.redirect{
  module = "initiative",
  view = "show",
  id = initiative.id
}
