local initiative = Initiative:by_id(param.get("initiative_id"))

local member = app.session.member
if member then
  initiative:load_everything_for_member_id(member.id)
  initiative.issue:load_everything_for_member_id(member.id)
end

local initiator = Initiator:by_pk(initiative.id, app.session.member.id)
if not initiator or initiator.accepted ~= true then
  return execute.view { module = "index", view = "403" }
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
          attr = { class = "vertical section" },
          module = "initiative",
          action = "remove_initiator",
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

            ui.heading { level = 3, content = _"Remove an initiator from initiative" }

            local records = initiative:get_reference_selector("initiating_members"):add_where("accepted OR accepted ISNULL"):exec()

            ui.field.select{
              name = "member_id",
              foreign_records = records,
              foreign_id = "id",
              foreign_name = "name",
            }
            slot.put("<br />")
            ui.tag{
              tag = "input",
              attr = {
                type = "submit",
                class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored",
                value = _"Remove initiator"
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
