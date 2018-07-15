local members = Member:new_selector():exec()

ui.list{
  records = members,
  columns = {
    {
      name = "id",
    },
    {
      name = "invite_code",
    },
    {
      content = function(member)
        ui.link{ content = _"Invite letter",  module = "admin", view = "invite_pdf", id = member.id }
      end
    }
  }
}
