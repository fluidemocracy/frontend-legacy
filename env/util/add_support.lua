function util.add_support(initiative_id, draft_id)

  local initiative = Initiative:new_selector():add_where{ "id = ?", initiative_id }:single_object_mode():exec()

  -- TODO important m1 selectors returning result _SET_!
  local issue = initiative:get_reference_selector("issue"):for_share():single_object_mode():exec()

  local member = app.access_token and app.access_token.member or app.session and app.session.member
  if not member then
    slot.put_into("error", "no valid session")
    return false
  end

  if not member:has_voting_right_for_unit_id(issue.area.unit_id) then
    slot.put_into("error", _"No voting rights.")
    return false
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

  if initiative.revoked then
    slot.put_into("error", _"This initiative is revoked")
    return false
  end

  local member = app.session.member

  local supporter = Supporter:by_pk(initiative.id, member.id)

  local last_draft = Draft:new_selector()
    :add_where{ "initiative_id = ?", initiative.id }
    :add_order_by("id DESC")
    :limit(1)
    :single_object_mode()
    :exec()
    
  if draft_id and draft_id ~= last_draft.id then
    slot.select("error", function()
      ui.tag{ content = _"The initiative draft has been updated again in the meanwhile, support not updated!" }
    end)
    return false
  end

  if not supporter then
    supporter = Supporter:new()
    supporter.member_id = member.id
    supporter.initiative_id = initiative.id
    supporter.draft_id = last_draft.id
    supporter:save()
  elseif supporter.draft_id ~= last_draft.id then
    supporter.draft_id = last_draft.id
    supporter:save()
    slot.put_into("notice", _"Your support has been updated to the latest draft")
  else
    slot.put_into("notice", _"You are already supporting the latest draft")
  end

  return true

end

