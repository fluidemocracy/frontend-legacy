local search_for = param.get("search_for", atom.string) or "global"
local search_string = param.get("q", atom.string)

if search_string then
  ui.title ( _("Search results for: '#{search}'", { search  = search_string } ) )
else
  ui.title ( _"Search" )
end

ui.grid{ content = function()
  ui.cell_main{ content = function()

    if not search_string then
      return
    end

    local issues_selector = Issue:get_search_selector(search_string)
    local count = issues_selector:count()
    local text
    if count == 0 then
      text = _"No matching issues found"
    elseif count == 1 then
      text = _"1 matching issue found"
    else
      text = _"#{count} matching issues found"
    end
        
    ui.section( function()
      ui.sectionHead( function()
        ui.heading { level = 1, content = _(text, { count = count }) }
      end )
      if count > 0 then
        execute.view{
          module = "issue",
          view = "_list",
          params = {
            search = search_string,
            no_filter = true
          },
        }
      end
    end)

    slot.put("<br />")

    local members_selector = Member:get_search_selector(search_string)
    local count = members_selector:count()
    local text
    if count == 0 then
      text = _"No matching members found"
    elseif count == 1 then
      text = _"1 matching member found"
    else
      text = _"#{count} matching members found"
    end
    if app.session:has_access("everything") then
      ui.section( function()
        ui.sectionHead( function()
          ui.heading { level = 1, content = _(text, { count = count }) }
        end )
        if count > 0 then
          execute.view{
            module = "member",
            view = "_list",
            params = {
              members_selector = members_selector,
              no_filter = true
            },
          }
        end
      end )
    end


  end }
end }
