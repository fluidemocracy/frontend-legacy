ui.title(_"Cancel issue")

ui.actions()

local id = param.get("id")

if not id then
  ui.form{
    module = "admin",
    view = "cancel_issue",
    content = function()
      ui.field.text{ label = _"Issue ID", name = "id" }
      ui.submit{ text = _"Cancel issue" }
    end
  }
else

  local issue = Issue:by_id(id)
  issue:load("initiatives")
    
  execute.view{ module = "initiative", view = "_list", params = {
    issue = issue, initiatives = issue.initiatives
  } }

  ui.form{
    module = "admin",
    action = "cancel_issue",
    id = id,
    content = function()
      ui.field.text{ label = _"Administraive notice", name = "id" }
      ui.submit{ text = _"Cancel issue now" }
    end
  }

end
