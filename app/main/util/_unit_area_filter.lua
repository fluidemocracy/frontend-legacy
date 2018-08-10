local member = app.session.member
local units
if member then
  units = member:get_reference_selector("units"):add_order_by("name"):exec()
  units:load_delegation_info_once_for_member_id(member.id)
else
  units = Unit:new_selector():add_where("active"):add_order_by("name"):exec()
end

ui.tag{ tag = "button", attr = { id = "unit-menu", class = "mdl-button mdl-js-button" }, content = function()
  ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "filter_list" }
  ui.tag{ content = _"All units" }
end }
ui.tag{ tag = "ul", attr = { class = "mdl-menu mdl-menu--top-left mdl-js-menu mdl-js-ripple-effect", ["data-mdl-for"]="unit-menu" }, content = function()
  if #units > 0 then
    for i, unit in ipairs(units) do
      local class = "mdl-navigation__link mdl-navigation__head" 
      if i == #units then
        class = class .. " mdl-menu__item--full-bleed-divider"
      end
      ui.tag{ tag = "li", attr = { class = "mdl-menu__item" }, content = function()
        ui.link{ attr = { class = classx }, content = unit.name, module = "unit", view = "show", id = unit.id }
      end }
    end
  end
end }

if app.current_unit then
  ui.tag{ tag = "button", attr = { id = "area-menu", class = "mdl-button mdl-js-button mdl-button--icon" }, content = function()
    ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "more_vert" }
  end }
  ui.tag{ content = _"All units" }
  ui.tag{ tag = "ul", attr = { class = "mdl-menu mdl-menu--top-left mdl-js-menu mdl-js-ripple-effect", ["data-mdl-for"]="area-menu" }, content = function()
    for i, area in ipairs({}) do
      local class = "mdl-navigation__link mdl-menu__item--small" 
      if i == #areas then
        class = class .. " mdl-menu__item--full-bleed-divider"
      end
      ui.tag{ tag = "li", attr = { class = "mdl-menu__item" }, content = function()
        ui.link{ attr = { class = classx }, module = "area", view = "show", id = area.id, content = area.name }
      end }
    end
  end }
end
