local initiative = Initiative:by_id(param.get("initiative_id"))

local issue

if initiative then
  issue = initiative.issue
else
  issue = Issue:by_id(param.get("issue_id"))
end

if not issue then
  execute.view { module = "index", view = "404" }
  request.set_status("404 Not Found")
  return
end


if app.session.member_id then
  if initiative then
    initiative:load_everything_for_member_id(app.session.member.id)
  end
  issue:load_everything_for_member_id(app.session.member.id)
end

local member = Member:by_id(param.get("member_id", atom.integer))

local members_selector = Member:new_selector()
  :join("delegating_voter", nil, "delegating_voter.member_id = member.id")
  :add_where{ "delegating_voter.issue_id = ?", issue.id }
  :add_where{ "delegating_voter.delegate_member_ids[1] = ?", member.id }
  :add_field("delegating_voter.weight", "voter_weight")
  :add_field("delegating_voter.ownweight", "ownweight")
  :join("issue", nil, "issue.id = delegating_voter.issue_id")

execute.view{ module = "issue", view = "_head", params = { issue = issue, link_issue = true } }
  

ui.grid{ content = function()
  
  ui.cell_main{ content = function()

    ui.container { attr = { class = "mdl-card mdl-shadow--2dp mdl-card__fullwidth" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _("Incoming delegations for '#{member}'", { member = member.name }) }
      end }
      ui.container{ attr = { class = "mdl-card__content" }, content = function()
        execute.view{
          module = "member",
          view = "_list",
          params = { 
            members_selector = members_selector,
            issue = issue,
            trustee = member
            initiative = initiative,
            for_votes = true, no_filter = true,
          }
        }
      end }
    end }
  end }
  
  ui.cell_sidebar{ content = function()
    execute.view {
      module = "issue", view = "_sidebar", 
      params = {
        issue = issue,
        member = app.session.member
      }
    }

    execute.view { 
      module = "issue", view = "_sidebar_members", params = {
        issue = issue
      }
    }

  end }

end }


