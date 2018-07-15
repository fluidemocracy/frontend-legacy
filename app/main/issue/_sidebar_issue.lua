local issue = param.get("issue", "table")
local ommit_initiative_id = param.get ( "ommit_initiative_id", "number" )

--[[
ui.heading {
  level = 2,
  content = _"Competing initiatives"
}
--]]

if #(issue.initiatives) > (ommit_initiative_id and 1 or 0) then
  execute.view {
    module = "initiative", view = "_list",
    params = {
      issue = issue,
      initiatives = issue.initiatives,
      ommit_initiative_id = ommit_initiative_id
    }
  }
end

if #issue.initiatives == 1 then
  ui.container { attr = { class = "mdl-card__content" }, content = function()
    if not issue.closed and not (issue.state == "voting") then
      ui.tag { content = _"Currently this is the only initiative in this issue, because nobody started a competing initiative (yet)." }
    else
      ui.container { content = _"This is the only initiative in this issue, because nobody started a competing initiative." }
    end
  end }
end

if app.session.member 
    and app.session.member:has_voting_right_for_unit_id(issue.area.unit_id) 
    and not issue.closed and not issue.fully_frozen 
then
  ui.container{ attr = { class = "mdl-card__actions mdl-card--border" }, content = function()
    ui.link {
      attr = { class = "mdl-button mdl-js-button" },
      module = "initiative", view = "new", 
      params = { issue_id = issue.id },
      content = _"start a new competing initiative"
    }
  end }
end
