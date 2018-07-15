local draft = Draft:new_selector():add_where{ "id = ?", param.get_id() }:optional_object_mode():exec()

if not draft then
  execute.view { module = "index", view = "404" }
  request.set_status("404 Not Found")
  return
end


local source = param.get("source", atom.boolean)

execute.view{
  module = "issue",
  view = "_head",
  params = { issue = draft.initiative.issue }
}

ui.section( function()
  
  ui.sectionHead( function()
    ui.link{
      module = "initiative", view = "show", id = draft.initiative.id,
      content = function ()
        ui.heading { 
          level = 1,
          content = draft.initiative.display_name
        }
      end
    }
    ui.container { attr = { class = "right" }, content = function()
      if source then
        ui.link{
          content = _"Rendered",
          module = "draft",
          view = "show",
          id = param.get_id(),
          params = { source = false }
        }
      else
        ui.link{
          content = _"Source",
          module = "draft",
          view = "show",
          id = param.get_id(),
          params = { source = true }
        }
      end
    end }
    ui.heading { level = 2, content = _("Draft revision #{id}", { id = draft.id } ) }
  end)
  
  if config.render_external_reference and config.render_external_reference.draft then
    config.render_external_reference.draft(draft, function (callback)
      ui.sectionRow(callback)
    end)
  end
  
  ui.sectionRow( function()
  
    execute.view{
      module = "draft",
      view = "_show",
      params = { draft = draft, source = source }
    }
  end)
end)
