local initiative = Initiative:by_id(param.get_id())
local initiatives = app.session.member
  :get_reference_selector("supported_initiatives")
  :join("issue", nil, "issue.id = initiative.issue_id")
  :add_where("issue.closed ISNULL")
  :add_order_by("issue.id")
  :exec()

  
local member = app.session.member
if member then
  initiative:load_everything_for_member_id(member.id)
  initiative.issue:load_everything_for_member_id(member.id)
end


local tmp = { { id = -1, myname = _"Suggest no initiative" }}
for i, initiative in ipairs(initiatives) do
  initiative.myname = _("Issue ##{issue_id}: #{initiative_name}", {
    issue_id = initiative.issue.id,
    initiative_name = initiative.name
  })
  tmp[#tmp+1] = initiative
end

execute.view {
  module = "issue", view = "_head", params = {
    issue = initiative.issue,
    member = member
  }
}

ui.grid{ content = function()
  ui.cell_main{ content = function()

    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()

      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Revoke initiative" }
      end }

      ui.container{ attr = { class = "mdl-card__content" }, content = function()

        ui.form{
          attr = { class = "wide section" },
          module = "initiative",
          action = "revoke",
          id = initiative.id,
          routing = {
            ok = {
              mode = "redirect",
              module = "initiative",
              view = "show",
              id = initiative.id
            }
          },
          content = function()

            ui.container{ content = _"Do you want to suggest to support another initiative?" }
            ui.container{ content = _"You may choose one of the ongoing initiatives you are currently supporting" }

            slot.put("<br />")          

            ui.field.select{
              name = "suggested_initiative_id",
              foreign_records = tmp,
              foreign_id = "id",
              foreign_name = "myname",
              value = param.get("suggested_initiative_id", atom.integer)
            }
            slot.put("<br />")
            ui.container { content = _"Are you aware that revoking an initiative is irrevocable?" }
            slot.put("<br />")          
            ui.container{ content = function()
              ui.tag{ tag = "input", attr = {
                type = "checkbox",
                name = "are_you_sure",
                value = "1"
              } }
              ui.tag { content = _"I understand, that this is not revocable" }
            end }
            
            
            slot.put("<br />")
            ui.tag{
              tag = "input",
              attr = {
                type = "submit",
                class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored",
                value = _"Revoke now"
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
