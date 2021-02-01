local issue = param.get("issue", "table")
local initiative = param.get("initiative", "table")

local member = param.get ( "member", "table" )

ui.container{ attr = { class = "mdl-card mdl-shadow--2dp mdl-card__fullwidth" }, content = function()

  ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
    ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = issue.name }
  end }

  if issue.admin_notice then
    ui.container{ attr = { class = "mdl-card__content mdl-card--border phases" }, content = function()
      slot.put(encode.html_newlines(issue.admin_notice)) 
    end }
  end

  ui.container{ attr = { class = "mdl-card__content mdl-card--border phases" }, content = function()
    execute.view{ module = "issue", view = "_sidebar_state", params = {
      issue = issue
    } }
  end }

  if app.session.member then
    if issue.fully_frozen then
      if issue.member_info.direct_voted then
        ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
          ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "mail_outline" }
          slot.put(" ")
          ui.tag { content = _"You have voted" }
        end }
      elseif active_trustee_id then
        ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
          ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "mail_outline" }
          slot.put(" ")
          ui.tag { content = _"You have voted via delegation" }
        end }
      end
    elseif not issue.closed then
      if issue.member_info.own_participation then
        ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
          ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "star" }
          slot.put(" ")
          ui.tag{ content = _"You are interested in this issue" }
        end }
      end
    end

    if not issue.closed then
      ui.container{ attr = { class = "mdl-card__actions" }, content = function()
        if issue.fully_frozen then
          if issue.member_info.direct_voted then
            if not issue.closed then
              ui.link {
                attr = { class = "mdl-button mdl-js-button" },
                module = "vote", view = "list", 
                params = { issue_id = issue.id },
                text = _"change vote"
              }
            else
              ui.link {
                attr = { class = "mdl-button mdl-js-button" },
                module = "vote", view = "list", 
                params = { issue_id = issue.id },
                text = _"show vote"
              }
            end
          elseif active_trustee_id then
            ui.link {
              attr = { class = "mdl-button mdl-js-button" },
              content = _"Show voting ballot",
              module = "vote", view = "list", params = {
                issue_id = issue.id, member_id = active_trustee_id
              }
            }
          elseif not issue.closed then
            ui.link {
              attr = { class = "mdl-button mdl-js-button" },
              module = "vote", view = "list", 
              params = { issue_id = issue.id },
              text = _"vote now"
            }
          end
        elseif not issue.closed then
          if issue.member_info.own_participation then
            ui.link {
              attr = { class = "mdl-button mdl-js-button" },
              module = "interest", action = "update", 
              params = { issue_id = issue.id, interested = false },
              routing = { default = {
                mode = "redirect", module = initiative and "initiative" or "issue", view = "show", id = initiative and initiative.id or issue.id
              } },
              text = _"remove my interest"
            }
          else
            ui.link {
              attr = { class = "mdl-button mdl-js-button" },
              module = "interest", action = "update", 
              params = { issue_id = issue.id, interested = true },
              routing = { default = {
                mode = "redirect", module = initiative and "initiative" or "issue", view = "show", id = initiative and initiative.id or issue.id
              } },
              content = function()
                ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "star" }
                slot.put(" ")
                ui.tag{ content = _"add my interest" }
              end 
            }
          end
        end
      end }
    end
  end
  
end }

if initiative then

  ui.container{ attr = { class = "mdl-card mdl-shadow--2dp mdl-card__fullwidth" }, content = function()
    ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
      ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Competing initiatives" }
    end }

    execute.view { 
      module = "issue", view = "_sidebar_issue", 
      params = {
        issue = issue,
        ommit_initiative_id = initiative.id
      }
    }

  end }
end
