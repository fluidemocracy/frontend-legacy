local issue = Issue:by_id ( param.get_id () )

if not issue then
  return execute.view { module = "index", view = "404" }
end

app.current_issue = issue

issue.area:load_delegation_info_once_for_member_id(app.session.member_id)

execute.view{ module = "issue", view = "_head", params = { issue = issue } }

local initiatives = issue.initiatives

if app.session.member_id then
  issue:load_everything_for_member_id ( app.session.member_id )
  initiatives:load_everything_for_member_id ( app.session.member_id )
end

if not app.html_title.title then
  app.html_title.title = _("Issue ##{id}", { id = issue.id })
end

ui.grid{ content = function()
  
  ui.cell_main{ content = function()

    ui.container { attr = { class = "mdl-card mdl-shadow--2dp mdl-card__fullwidth" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Competing initiatives" }
      end }
      execute.view {
        module = "initiative", view = "_list",
        params = { 
          issue = issue,
          initiatives = initiatives
        }
      }
    end }

    ui.container { attr = { class = "mdl-card mdl-shadow--2dp mdl-card__fullwidth" }, content = function()

      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Details" }
      end }

      ui.container{ attr = { class = "mdl-card__content" }, content = function()
        local policy = issue.policy
        ui.form{
          record = issue,
          readonly = true,
          attr = { class = "sectionRow form" },
          content = function()
            if issue.snapshot then
              ui.field.timestamp{ label = _"Last counting:", value = issue.snapshot }
            end
            ui.field.text{       label = _"Population",            name = "population" }
            ui.field.timestamp{  label = _"Created at",            name = "created" }
            if policy.polling then
              ui.field.text{       label = _"Admission time",        value = _"Implicitly admitted" }
            else
              ui.field.text{       label = _"Minimum admission time",        value = format.interval_text(issue.min_admission_time_text) }
              ui.field.text{       label = _"Maximum admission time",        value = format.interval_text(issue.max_admission_time_text) }
              ui.field.text{ label = _"Issue quorum", value = issue.issue_quorum }
            end
            if issue.accepted then
              ui.field.timestamp{  label = _"Accepted at",           name = "accepted" }
            end
            ui.field.text{       label = _"Discussion time",       value = format.interval_text(issue.discussion_time_text) }
            if issue.half_frozen then
              ui.field.timestamp{  label = _"Half frozen at",        name = "half_frozen" }
            end
            ui.field.text{       label = _"Verification time",     value = format.interval_text(issue.verification_time_text) }
            local quorums = {}
            if policy.initiative_quorum_num / policy.initiative_quorum_den then
              table.insert(quorums, format.percentage(policy.initiative_quorum_num / policy.initiative_quorum_den))
            end
            if policy.initiative_quorum then
              table.insert(quorums, policy.initiative_quorum)
            end
            ui.field.text{
              label   = _"Initiative quorum",
              value = table.concat(quorums, " / ")
            }
            if issue.fully_frozen then
              ui.field.timestamp{  label = _"Fully frozen at",       name = "fully_frozen" }
            end
            ui.field.text{       label = _"Voting time",           value = format.interval_text(issue.voting_time_text) }
            if issue.closed then
              ui.field.timestamp{  label = _"Closed",                name = "closed" }
            end
          end
        }

        if issue.initiatives[1].rank == 1 then
          execute.view{ module = "initiative", view = "_sidebar_state", params = {
            initiative = issue.initiatives[1]
          } }
        end
    
      end }
      
    end }
      
  end }

  ui.cell_sidebar{ content = function()
    if config.logo then
      config.logo()
    end
    execute.view {
      module = "issue", view = "_sidebar", 
      params = {
        issue = issue,
        member = app.session.member
      }
    }

    execute.view {
      module = "issue", view = "_sidebar_whatcanido", 
      params = {
        issue = issue,
        member = app.session.member
      }
    }

    if not config.voting_only or issue.state ~= "voting" then
      execute.view { 
        module = "issue", view = "_sidebar_members", params = {
          issue = issue
        }
      }
    end
  end }

end }
