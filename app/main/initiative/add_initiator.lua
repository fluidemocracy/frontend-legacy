local initiative = Initiative:by_id(param.get("initiative_id"))

local member = app.session.member
if member then
  initiative:load_everything_for_member_id(member.id)
  initiative.issue:load_everything_for_member_id(member.id)
end


local records = {
  {
    id = "-1",
    name = _"Choose member"
  }
}
local contact_members = app.session.member:get_reference_selector("saved_members"):add_order_by("name"):exec()
for i, record in ipairs(contact_members) do
  records[#records+1] = record
end

execute.view {
  module = "issue", view = "_head", params = {
    issue = initiative.issue,
    member = app.session.member
  }
}

ui.grid{ content = function()
  ui.cell_main{ content = function()

    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()

      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = initiative.display_name }
      end }

      ui.container{ attr = { class = "mdl-card__content" }, content = function()
        ui.form{
          attr = { class = "wide section" },
          module = "initiative",
          action = "add_initiator",
          params = {
            initiative_id = initiative.id,
          },
          routing = {
            ok = {
              mode = "redirect",
              module = "initiative",
              view = "show",
              id = initiative.id,
              params = {
                tab = "initiators",
              }
            }
          },
          content = function()

            ui.heading { level = 3, content = _"Invite an initiator to initiative" }
            ui.container{ content = _"You can choose only members which you have been saved as contact before." }
            slot.put("<br />")
            ui.field.select{
              name = "member_id",
              foreign_records = records,
              foreign_id = "id",
              foreign_name = "name"
            }
           slot.put("<br />")
           slot.put("<br />")
            ui.tag{
              tag = "input",
              attr = {
                type = "submit",
                class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored",
                value = _"Invite member"
              },
              content = ""
            }
            slot.put(" &nbsp; ")
            ui.link{
              attr = { class = "mdl-button mdl-js-button mdl-button--raised" },
              content = _"Cancel",
              module = "initiative",
              view = "show",
              id = initiative.id,
              params = {
                tab = "initiators"
              }
            }
          end
        }

      end }
    end }
  end }

end }


