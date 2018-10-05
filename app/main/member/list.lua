ui.title(_"Member list")

local unit_id = param.get("unit_id", atom.integer)

local members_selector = Member:new_selector()
  :add_where("activated NOTNULL")

if unit_id then
  members_selector:join("privilege", nil, { "privilege.member_id = member.id AND privilege.unit_id = ?", unit_id })
end

ui.grid{ content = function()
  ui.cell_full{ content = function()

    ui.container { attr = { class = "mdl-card mdl-shadow--2dp mdl-card__fullwidth" }, content = function()

      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Member list" }
      end }
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
        execute.view{
          module = "member",
          view = "_list",
          params = { members_selector = members_selector }
        }
      end }
    end }
  end }
end }
