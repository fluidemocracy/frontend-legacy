Opinion = mondelefant.new_class()
Opinion.table = 'opinion'
Opinion.primary_key = { "member_id", "suggestion_id" } 

Opinion:add_reference{
  mode          = 'm1',
  to            = "Initiative",
  this_key      = 'initiative_id',
  that_key      = 'id',
  ref           = 'initiative',
}

Opinion:add_reference{
  mode          = 'm1',
  to            = "Suggestion",
  this_key      = 'suggestion_id',
  that_key      = 'id',
  ref           = 'suggestion',
}

Opinion:add_reference{
  mode          = 'm1',
  to            = "Member",
  this_key      = 'member_id',
  that_key      = 'id',
  ref           = 'member',
}

function Opinion:by_pk(member_id, suggestion_id)
  return self:new_selector()
    :add_where{ "member_id = ?",     member_id }
    :add_where{ "suggestion_id = ?", suggestion_id }
    :optional_object_mode()
    :exec()
end


function Opinion:update(suggestion_id, member_id, degree, fulfilled)

  local opinion = Opinion:by_pk(member_id, suggestion_id)
  local suggestion = Suggestion:by_id(suggestion_id)

  if not suggestion then
    slot.put_into("error", _"This suggestion has been meanwhile deleted")
    return false
  end

  -- TODO important m1 selectors returning result _SET_!
  local issue = suggestion.initiative:get_reference_selector("issue"):for_share():single_object_mode():exec()

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

  if degree == 0 then
    if opinion then
      opinion:destroy()
    end
    return true
  end

  if degree ~= 0 and not app.session.member:has_voting_right_for_unit_id(suggestion.initiative.issue.area.unit_id) then
    return execute.view { module = "index", view = "403" }
  end

  if not opinion then
    opinion = Opinion:new()
    opinion.member_id     = member_id
    opinion.suggestion_id = suggestion_id
    opinion.fulfilled     = false
  end


  if degree ~= nil then
    opinion.degree = degree
  end

  if fulfilled ~= nil then
    opinion.fulfilled = fulfilled
  end

  opinion:save()
  return true

end
