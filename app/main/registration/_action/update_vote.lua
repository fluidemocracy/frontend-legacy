if not app.session.member then
  return
end

local cancel = param.get("cancel") and true or false
if cancel then return true end

local issue = Issue:new_selector():add_where{ "id = ?", param.get("issue_id", atom.integer) }:for_share():single_object_mode():exec()


if not app.session.member:has_voting_right_for_unit_id(issue.area.unit_id) then
  return execute.view { module = "index", view = "403" }
end

if issue.state ~= "voting" and not issue.closed then
  slot.put_into("error", _"Voting has not started yet.")
  return false
end

if issue.phase_finished or issue.closed and not update_comment then
  slot.put_into("error", _"This issue is already closed.")
  return false
end

local direct_voter = DirectVoter:by_pk(issue.id, app.session.member_id)

if param.get("discard") then
  if direct_voter then
    direct_voter:destroy()
  end
  slot.put_into("notice", _"Your vote has been discarded. Delegation rules apply if set.")
  return
end

local initiatives = issue:get_reference_selector("initiatives")
  :add_where("initiative.admitted")
  :add_order_by("initiative.satisfied_supporter_count DESC")
  :exec()

local vote_for_initiative_id = tonumber(param.get("vote_for_initiative_id"))
  
local voted = 0

for i, initiative in ipairs(initiatives) do
  if initiative.id == vote_for_initiative_id then
    voted = voted + 1
  end
end

if voted ~= 1 then
  slot.put_into("error", _"Please choose one project to vote for.")
  return false
end

if not direct_voter then
  direct_voter = DirectVoter:new()
  direct_voter.issue_id = issue.id
  direct_voter.member_id = app.session.member_id
  direct_voter:save()
else
  local votes = Vote:new_selector()
    :add_where{ "vote.issue_id = ?", issue.id } 
    :add_where{ "vote.member_id = ?", app.session.member_id }
    :exec()
  for i, vote in ipairs(votes) do
    vote:destroy()
  end
end

for i, initiative in ipairs(initiatives) do
  local vote = Vote:new()
  vote.issue_id = issue.id
  vote.initiative_id = initiative.id
  vote.member_id = app.session.member_id
  if initiative.id == vote_for_initiative_id then
    vote.grade = 1
  else
    vote.grade = 0
  end
  vote:save()
end
