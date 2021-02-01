Interest = mondelefant.new_class()
Interest.table = 'interest'
Interest.primary_key = { "issue_id", "member_id" }
Interest:add_reference{
  mode          = 'm1',
  to            = "Member",
  this_key      = 'member_id',
  that_key      = 'id',
  ref           = 'member',
}

Interest:add_reference{
  mode          = 'm1',
  to            = "Issue",
  this_key      = 'issue_id',
  that_key      = 'id',
  ref           = 'issue',
}

function Interest:by_pk(issue_id, member_id)
  return self:new_selector()
    :add_where{ "issue_id = ? AND member_id = ?", issue_id, member_id }
    :optional_object_mode()
    :exec()
end

function Interest:update(issue_id, member, interested)
  local interest = Interest:by_pk(issue_id, member.id)

  local issue = Issue:new_selector():add_where{ "id = ?", issue_id }:for_share():single_object_mode():exec()

  if not member:has_voting_right_for_unit_id(issue.area.unit_id) then
    return execute.view { module = "index", view = "403" }
  end

  if issue.closed then
    slot.put_into("error", _"This issue is already closed.")
    return false
  elseif issue.fully_frozen then 
    slot.put_into("error", _"Voting for this issue has already begun.")
    return false
  elseif 
    (issue.half_frozen and issue.phase_finished) or
    (not issue.accepted and issue.phase_finished) 
  then
    slot.put_into("error", _"Current phase is already closed.")
    return false
  end

  if interested == false then
    if interest then
      interest:destroy()
    end
    return true
  end

  if not interest then
    interest = Interest:new()
    interest.issue_id   = issue_id
    interest.member_id  = app.session.member_id
    interest:save()
  end

  return true
  
end
