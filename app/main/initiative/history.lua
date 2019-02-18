local initiative = Initiative:by_id(param.get_id())

initiative:load_everything_for_member_id(app.session.member_id)
initiative.issue:load_everything_for_member_id(app.session.member_id)


ui.grid{ content = function()

  ui.cell_main{ content = function()
    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()

      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function ()
        ui.heading { 
          attr = { class = "mdl-card__title-text" },
          content = function()
            ui.link{
              module = "initiative", view = "show", id = initiative.id,
              content = initiative.display_name
            }
          end
        }
        ui.container { content = _"Draft history" }
      end }
      
      ui.container {
        attr = { class = "mdl-card__content" },
        content = function()
          ui.form{
            method = "get",
            module = "draft",
            view = "diff",
            attr = { class = "section" },
            content = function()
              ui.field.hidden{ name = "initiative_id", value = initiative.id }
            
              ui.sectionRow( function()
              
                local columns = {
                  {
                    content = function(record)
                      slot.put('<label class="mdl-radio mdl-js-radio mdl-js-ripple-effect" for="old_draft_id_' .. record.id .. '"><input type="radio" class="mdl-radio__button" id="old_draft_id_' .. record.id .. '" name="old_draft_id" value="' .. tostring(record.id) .. '">') 
                      ui.tag { content = "compare" }
                      slot.put(" ")
                      ui.link{
                        attr = { class = "action" },
                        module = "draft", view = "show", id = record.id,
                        text = format.timestamp(record.created)
                      }
                      slot.put("</label>")
                    end
                  },
                  {
                    content = function(record)
                      slot.put('<label class="mdl-radio mdl-js-radio mdl-js-ripple-effect" for="new_draft_id_' .. record.id .. '"><input type="radio" class="mdl-radio__button" id="new_draft_id_' .. record.id .. '" name="new_draft_id" value="' .. tostring(record.id) .. '">')
                      ui.tag { content = _"with" }
                      slot.put(" ")
                      ui.link{
                        attr = { class = "action" },
                        module = "draft", view = "show", id = record.id,
                        text = format.timestamp(record.created)
                      }
                      slot.put("</label>")
                    end
                  }
                }
                
                if app.session:has_access("authors_pseudonymous") then
                  columns[#columns+1] = {
                    label = _"author",
                    content = function(record)
                      if record.author then
                        return util.micro_avatar ( record.author )
                      end
                    end
                  }
                end
                
                if config.render_external_reference and config.render_external_reference.draft then
                  columns[#columns+1] = {
                    label = _"external reference",
                    content = function(draft)
                      config.render_external_reference.draft(draft, function (callback)
                        callback()
                      end)
                    end
                  }
                end
                
                ui.list{
                  records = initiative.drafts,
                  columns = columns
                }
                
                slot.put("<br />")
                ui.container { attr = { class = "actions" }, content = function()
                  ui.tag{
                    tag = "input",
                    attr = {
                      type = "submit",
                      class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored",
                      value = _"compare revisions"
                    },
                    content = ""
                  }
                end }
              end )
            end
          }
        end
      }
    end }
  end }
  
  ui.cell_sidebar{ content = function()
    execute.view{ module = "issue", view = "_sidebar", params = {
      initiative = initiative,
      issue = initiative.issue
    } }

    execute.view {
      module = "issue", view = "_sidebar_whatcanido",
      params = { initiative = initiative }
    }

    execute.view { 
      module = "issue", view = "_sidebar_members", params = {
        issue = initiative.issue, initiative = initiative
      }
    }
  end }
  
end }
