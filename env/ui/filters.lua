local function filters(args)

  local el_id = ui.create_unique_id()
  local class = "lf-filter"
  if args.class then
    class = class .. " " .. args.class
  end
  ui.container{
    attr = { class = { class } },
    content = function()
      for idx, filter in ipairs(args) do
        local filter_name = filter.name or "filter"
        local current_option_name = atom.string:load(request.get_param{ name = filter_name })
        if not current_option_name then
          current_option_name = param.get(filter_name)
        end
        local current_option = filter[1]
        for idx, option in ipairs(filter) do
          if current_option_name == option.name then
            current_option = option
          end
        end
        if not current_option_name or #current_option_name == 0 or not current_option then
          current_option_name = filter[1].name
        end
        ui.tag{ tag = "button", attr = { id = "filter-" .. filter_name .. "-menu", class = "mdl-button mdl-js-button" }, content = function()
          ui.tag{ content = current_option.label }
          slot.put(" ")
          ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "arrow_drop_down" }
        end }
        local id     = request.get_id_string()
        local params = request.get_param_strings()
        local class = "mdl-menu mdl-js-menu mdl-js-ripple-effect"
        if filter.class then
          class = class .. " " .. filter.class
        end
        ui.tag{
          tag = "ul",
          attr = { class = class, ["data-mdl-for"] = "filter-" .. filter_name .. "-menu" },
          content = function()
            for idx, option in ipairs(filter) do
              params[filter_name] = option.name
              local attr = {}
              attr.class = "mdl-menu__link"
              if current_option_name == option.name then
                attr.class = attr.class .. " active"
                option.selector_modifier(args.selector)
              end
              if idx > 1 then
                slot.put(" ")
              end
              ui.tag{
                tag = "li",
                attr = { class = "mdl-menu__item" },
                content = function()
                  ui.link{
                    attr    = attr,
                    module  = request.get_module(),
                    view    = request.get_view(),
                    id      = id,
                    params  = params,
                    content = option.label,
                    partial = {
                      params = {
                        [filter_name] = idx > 1 and option.name or nil
                      }
                    }
                  }
                end
              }
            end
          end
        }
      end
    end
  }
end
  
function ui.filters(args)
  if args.slot then
    slot.select(args.slot, function()
      filters(args)
    end)
  else
    filters(args)
  end
  ui.container{
    attr = { class = "ui_filter_content" },
    content = function()
      args.content()
    end
  }
end
