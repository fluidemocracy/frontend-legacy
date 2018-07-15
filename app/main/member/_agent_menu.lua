if app.session.real_member_id then
  local member = Member:by_id(app.session.real_member_id)
  ui.tag{ tag = "li", attr = { class = item_class }, content = function()
    ui.link{
      content = _("switch to: #{member_name}", { member_name = member.display_name }),
      attr = { class = link_class },
      module  = "role",
      action    = "switch"
    }
  end }
end

local member_id = app.session.real_member_id or app.session.member_id

local controlled_members_count = Member:new_selector()
  :join("agent", nil, "agent.controlled_id = member.id")
  :add_where("agent.accepted")
  :add_where("NOT member.locked")
  :add_where{ "agent.controller_id = ?", member_id }
  :exec()
  
for i, member in ipairs(controlled_members_count) do
  if member.id ~= app.session.member_id then
    ui.tag{ tag = "li", attr = { class = item_class }, content = function()
      ui.link{
        content = _("switch to: #{member_name}", { member_name = member.identification }),
        attr = { class = link_class },
        module  = "role",
        action    = "switch",
        id = member.id
      }
    end }
  end
end

