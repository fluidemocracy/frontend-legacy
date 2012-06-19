
local tabs = {
  module = "index",
  view = "index"
}

local areas_selector = app.session.member:get_reference_selector("areas")
tabs[#tabs+1] = {
  name = "areas",
  label = _"Home",
  icon = { static = "icons/16/package.png" },
  module = "index",
  view = "_member_home",
  params = { areas_selector = areas_selector, member = app.session.member, for_member = true },
}

tabs[#tabs+1] = {
  name = "timeline",
  label = _"Latest events",
  module = "member",
  view = "_event_list",
  params = { }
}


tabs[#tabs+1] = {
  name = "open",
  label = _"Open issues",
  module = "issue",
  view = "_list",
  params = {
    for_state = "open",
    issues_selector = Issue:new_selector()
      :add_where("issue.closed ISNULL")
      :add_order_by("coalesce(issue.fully_frozen + issue.voting_time, issue.half_frozen + issue.verification_time, issue.accepted + issue.discussion_time, issue.created + issue.admission_time) - now()")
  }
}

tabs[#tabs+1] = {
  name = "closed",
  label = _"Closed issues",
  module = "issue",
  view = "_list",
  link_params = { 
    filter_interest = not show_as_homepage and "issue" or nil,
  },
  params = {
    for_state = "closed",
    issues_selector = Issue:new_selector()
      :add_where("issue.closed NOTNULL")
      :add_order_by("issue.closed DESC")

  }
}

tabs[#tabs+1] = {
  name = "members",
  label = _"Members",
  module = 'member',
  view   = '_list',
  params = { members_selector = Member:new_selector() }
}


ui.tabs(tabs)