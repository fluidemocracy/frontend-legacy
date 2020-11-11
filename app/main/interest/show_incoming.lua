local issue = Issue:by_id(param.get("issue_id", atom.integer))
local member = Member:by_id(param.get("member_id", atom.integer))

if not issue or not member then
  return execute.view { module = "index", view = "404" }
end

if app.session.member_id then
  issue:load_everything_for_member_id ( app.session.member_id )
end


local members_selector = Member:new_selector()
  :join("delegating_interest_snapshot", nil, "delegating_interest_snapshot.member_id = member.id")
  :join("issue", nil, "issue.id = delegating_interest_snapshot.issue_id")
  :add_where{ "delegating_interest_snapshot.issue_id = ?", issue.id }
  :add_where{ "delegating_interest_snapshot.snapshot_id = ?", issue.latest_snapshot_id }
  :add_where{ "delegating_interest_snapshot.delegate_member_ids[1] = ?", member.id }
  :add_field{ "delegating_interest_snapshot.weight" }
  :add_field{ "delegating_interest_snapshot.ownweight" }

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
