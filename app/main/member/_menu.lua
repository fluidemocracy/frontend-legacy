local item_class = param.get("item_class")
local link_class = param.get("link_class")


ui.tag{ tag = "li", attr = { class = item_class }, content = function()
  ui.link{
    content = _"profile and settings",
    attr = { class = link_class },
    module  = "member",
    view    = "show",
    id = app.session.member_id
  }
end }

execute.view{ module = "member", view = "_agent_menu" }

ui.tag{ tag = "li", attr = { class = item_class }, content = function()
  ui.link{
    text   = _"logout",
    attr = { class = link_class },
    module = 'index',
    action = 'logout',
    routing = {
      default = {
        mode = "redirect",
        module = "index",
        view = "index"
      }
    }
  }
end }
