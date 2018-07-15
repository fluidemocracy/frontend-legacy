local initiative = Initiative:by_id ( param.get_id() )
local member = app.session.member

if not initiative then
  execute.view { module = "index", view = "404" }
  request.set_status("404 Not Found")
  return
end

app.current_initiative = initiative

local issue_info

if member then
  initiative:load_everything_for_member_id(member.id)
  initiative.issue:load_everything_for_member_id(member.id)
  issue_info = initiative.issue.member_info
end

local direct_supporter

if app.session.member_id then
  direct_supporter = initiative.issue.member_info.own_participation and initiative.member_info.supported
end

slot.put_into("header", initiative.display_name)

execute.view{ module = "issue", view = "_head", params = { issue = initiative.issue, link_issue = true } }

ui.grid{ content = function()

  ui.cell_main{ content = function()
    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      execute.view{
        module = "initiative", view = "_head", params = {
          initiative = initiative
        }
      }

      if direct_supporter and not initiative.issue.closed then
        local supporter = app.session.member:get_reference_selector("supporters")
          :add_where{ "initiative_id = ?", initiative.id }
          :optional_object_mode()
          :exec()
          
        if supporter then

          local old_draft_id = supporter.draft_id
          local new_draft_id = initiative.current_draft.id
          
          if old_draft_id ~= new_draft_id then
            ui.container {
              attr = { class = "mdl-card__content mdl-card--no-bottom-pad mdl-card--notice" },
              content = _"The draft of this initiative has been updated!"
            }
            ui.container {
              attr = { class = "mdl-card__actions mdl-card--action-border  mdl-card--notice" },
              content = function ()
                if not initiative.revoked then
                  ui.link{
                    attr = { class = "mdl-button mdl-js-button mdl-button--raised" },
                    text   = _"refresh my support",
                    module = "initiative",
                    action = "add_support",
                    id     = initiative.id,
                    params = { draft_id = initiative.current_draft.id },
                    routing = {
                      default = {
                        mode = "redirect",
                        module = "initiative",
                        view = "show",
                        id = initiative.id
                      }
                    }
                  }
                  slot.put(" &nbsp; ")
                  ui.link{
                    attr = { class = "mdl-button mdl-js-button mdl-button--raised" },
                    content = _"show differences",
                    module = "draft",
                    view = "diff",
                    params = {
                      old_draft_id = old_draft_id,
                      new_draft_id = new_draft_id
                    }
                  }
                  slot.put(" &nbsp; ")
                end
                ui.link{
                  attr = { class = "mdl-button mdl-js-button mdl-button--raised" },
                  text   = _"remove my support",
                  module = "initiative",
                  action = "remove_support",
                  id     = initiative.id,
                  routing = {
                    default = {
                      mode = "redirect",
                      module = "initiative",
                      view = "show",
                      id = initiative.id
                    }
                  }
                }

              end
            }
          end
        end
      end

      if config.render_external_reference and config.render_external_reference.initiative then
        config.render_external_reference.initiative(initiative, function (callback)
          ui.sectionRow(callback)
        end)
      end
      local draft_content = initiative.current_draft.content
      if config.initiative_abstract then
        local abstract = string.match(draft_content, "(.+)<!%--END_OF_ABSTRACT%-->")
        if abstract then
          draft_content = string.match(draft_content, "<!%--END_OF_ABSTRACT%-->(.*)")
        end
      end
      ui.container {
        attr = { class = "draft mdl-card__content mdl-card--border" },
        content = function ()
          if initiative.current_draft.formatting_engine == "html" or not initiative.current_draft.formatting_engine then
            if config.draft_filter then
              slot.put(config.draft_filter(draft_content))
            else
              slot.put(draft_content)
            end
          else
            slot.put ( initiative.current_draft:get_content ( "html" ) )
          end
        end
      }
      
      local drafts_count = initiative:get_reference_selector("drafts"):count()
      
      if not config.voting_only then
        ui.container {
          attr = { class = "mdl-card__actions" },
          content = function()
            ui.link{
              attr = { class = "mdl-button mdl-js-button" },
              module = "initiative", view = "history", id = initiative.id,
              content = _("draft history (#{count})", { count = drafts_count })
            }
          end
        }
      end
    
    end }

    execute.view{ module = "initiative", view = "_suggestions", params = { initiative = initiative } }
    
  end }

  ui.cell_sidebar{ content = function()
    if config.logo then
      config.logo()
    end
    execute.view {
      module = "issue", view = "_sidebar", 
      params = {
        issue = initiative.issue,
        initiative = initiative,
        member = app.session.member
      }
    }

    execute.view {
      module = "issue", view = "_sidebar_whatcanido", 
      params = {
        issue = initiative.issue,
        initiative = initiative,
        member = app.session.member
      }
    }

    execute.view { 
      module = "issue", view = "_sidebar_members", params = {
        issue = initiative.issue, initiative = initiative
      }
    }

  end }

end }
