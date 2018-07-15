local issue = Issue:by_id(param.get_id())
issue:load_everything_for_member_id ( app.session.member_id )

execute.view{ 
  module = "issue", view = "_head", params = {
    issue = issue, for_history = true
  }
}

execute.view {
  module = "issue", view = "_list", params = { for_issue = issue }
}

execute.view { 
  module = "issue", view = "_sidebar_issue", params = {
    issue = issue,
    hide_initiatives = true
  }
}

execute.view { 
  module = "issue", view = "_sidebar_members", params = {
    issue = issue
  }
}



  
