local limit = 50

if not app.session:has_access("all_pseudonymous") then
  return
end

local unit_id = request.get_param{ name = "unit" }
if unit_id == "all" then
  unit_id = nil
end

local selector = Member:new_selector()
  :add_where("active")
  :add_order_by("last_login DESC NULLS LAST, id DESC")
  
if unit_id then
  selector:join("privilege", nil, "privilege.member_id = member.id")
  selector:add_where{ "privilege.unit_id = ?", unit_id }
end

local member_count = selector:count()

selector:limit(limit)


ui.container{ attr = { class = "mdl-card mdl-shadow--2dp mdl-card__fullwidth" }, content = function()

  ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
    local text
    if unit_id then
      text = _("Eligible members (#{count})", { count = selector:count() })
    else
      text = _("Registered members (#{count})", { count = selector:count() })
    end
    ui.container{
      attr = { class = "mdl-card__title-text" }, 
      content = text
    }
  end }
  
  ui.container{ attr = { class = "mdl-card__content" }, content = function()
    execute.view {
      module = 'member', view   = '_list', params = {
        members_selector = selector,
        no_filter = true, no_paginate = true,
        member_class = "sidebarRow sidebarRowNarrow"
      }
    }
  end }
  
  if member_count > limit then
    ui.container{ attr = { class = "mdl-card__actions mdl-card--border" }, content = function()
      ui.link {
        attr = { class = "mdl-button mdl-js-button" },
        text = _"Show full member list",
        module = "member", view = "list", params = {
          unit_id = unit_id
        }
      }
    end }
  end
end }
