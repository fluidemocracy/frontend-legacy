local issue = param.get("issue", "table")
local initiative = param.get("initiative", "table")

if config.voting_only and not issue.closed then
  return
end


if app.session:has_access("all_pseudonymous") then

  ui.container{ attr = { class = "mdl-card mdl-shadow--2dp mdl-card__fullwidth" }, content = function()
    
    ui.tag { tag = "a", attr = { name = "members" }, content = "" }
    ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
      local text = _"Interested members"
      if issue.state == "finished_with_winner" or issue.state == "finished_without_winner" then
        text = _"Voters"
      end
      
      ui.container{ attr = { class = "mdl-card__title-text" }, content = text }
    end }

    local interested_members_selector
    
    if issue.state == "finished_with_winner" or issue.state == "finished_without_winner" then
      if initiative then
        interested_members_selector = Member:new_selector()
          :join("issue", nil, { "issue.id = ?", issue.id })
          :join("direct_voter", nil, { "direct_voter.issue_id = ? AND direct_voter.member_id = member.id", issue.id })
          :join("vote", nil, { "vote.member_id = member.id AND vote.initiative_id = ?", initiative.id })
          :add_field("direct_voter.weight", "voter_weight")
          :add_field("vote.grade")
          :add_field("direct_voter.comment", "voter_comment")
      else
        interested_members_selector = Member:new_selector()
          :join("issue", nil, { "issue.id = ?", issue.id })
          :join("direct_voter", nil, { "direct_voter.issue_id = ? AND direct_voter.member_id = member.id", issue.id })
          :add_field("direct_voter.weight", "voter_weight")
          :add_field("direct_voter.comment", "voter_comment")
      end
    else
      interested_members_selector = issue:get_reference_selector("interested_members_snapshot")
        :join("issue", nil, "issue.id = direct_interest_snapshot.issue_id")
        :add_field("direct_interest_snapshot.weight")
        :add_where("direct_interest_snapshot.snapshot_id = issue.latest_snapshot_id")

      if initiative then
        interested_members_selector:left_join("direct_supporter_snapshot", nil, { "direct_supporter_snapshot.initiative_id = ? AND direct_interest_snapshot.issue_id = direct_supporter_snapshot.issue_id AND direct_supporter_snapshot.member_id = direct_interest_snapshot.member_id AND direct_supporter_snapshot.snapshot_id = issue.latest_snapshot_id", initiative.id })
        interested_members_selector:add_field("direct_supporter_snapshot.member_id NOTNULL", "supporter")
        interested_members_selector:add_field("satisfied", "supporter_satisfied")
      end
    end
    
    ui.container{ attr = { class = "mdl-card__content" }, content = function()
      execute.view{
        module = "member",
        view = "_list",
        params = {
          issue = issue,
          initiative = initiative,
          members_selector = interested_members_selector,
          paginator_name = "members",
          member_class = "sidebarRow sidebarRowNarrow",
          for_votes = issue.state == "finished_with_winner" or issue.state == "finished_without_winner",
          no_filter = true
        }
      }
    end }
  end }
end
