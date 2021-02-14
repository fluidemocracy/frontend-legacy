local initiative = param.get("initiative", "table")
local member = param.get("member", "table") or app.session.member

-- TODO performance
local initiator
if member then
  initiator = Initiator:by_pk(initiative.id, member.id)
end

local initiators_members_selector = initiative:get_reference_selector("initiating_members")
  :add_field("initiator.accepted", "accepted")
  :add_order_by("member.name")
if initiator and initiator.accepted then
  initiators_members_selector:add_where("initiator.accepted ISNULL OR initiator.accepted")
else
  initiators_members_selector:add_where("initiator.accepted")
end

local initiators = initiators_members_selector:exec()


ui.container{ attr = { class = "mdl-card__title mdl-card--has-fab mdl-card--border" }, content = function ()

  ui.heading { 
    attr = { class = "mdl-card__title-text" },
    level = 2,
    content = function()
      ui.tag{ content = initiative.display_name }
    end 
  }

  if app.session.member and app.session.member:has_voting_right_for_unit_id(initiative.issue.area.unit_id) then
    if not initiative.issue.closed and not initiative.member_info.supported then
      if not initiative.issue.fully_frozen then
        ui.link {
          attr = { class = "mdl-button mdl-js-button mdl-button--fab mdl-button--colored" ,
            style = "position: absolute; right: 20px; bottom: -27px;"
          },
          module = "initiative", action = "add_support", 
          routing = { default = {
            mode = "redirect", module = "initiative", view = "show", id = initiative.id
          } },
          id = initiative.id,
          content = function()
            ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "thumb_up" }
          end 
        }
      end
    end
    if initiative.issue.fully_frozen and not initiative.issue.closed and not initiative.issue.member_info.direct_voted then
      ui.link {
        attr = { class = "mdl-button mdl-js-button mdl-button--fab mdl-button--colored" ,
          style = "position: absolute; right: 20px; bottom: -27px;"
        },
        module = "vote", view = "list", 
        params = { issue_id = initiative.issue_id },
        content = function()
          ui.tag{ tag = "i", attr = { class = "material-icons" }, content = config.voting_icon or "mail_outline" }
        end 
      }
    end
  end
end }

ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function ()

  if not config.voting_only and app.session:has_access("authors_pseudonymous") then
    ui.tag{ content = _"by" }
    slot.put(" ")
    for i, member in ipairs(initiators) do
      if i > 1 then
        slot.put(" ")
      end
      ui.link{ module = "member", view = "show", id = member.id, content = member.name }
    end -- for i, member
  end
  
  if member then
    ui.container { attr = { class = "mySupport float-right right" }, content = function ()
      if initiative.issue.fully_frozen then
        slot.put("<br />")
        if initiative.issue.member_info.direct_voted then
          ui.tag { content = _"You have voted" }
          slot.put("<br />")
          if not initiative.issue.closed then
            ui.link {
              module = "vote", view = "list", 
              params = { issue_id = initiative.issue.id },
              text = _"change vote"
            }
          else
            ui.link {
              module = "vote", view = "list", 
              params = { issue_id = initiative.issue.id },
              text = _"show vote"
            }
          end
          slot.put(" ")
        elseif active_trustee_id then
          ui.tag { content = _"You have voted via delegation" }
          ui.link {
            content = _"Show voting ballot",
            module = "vote", view = "list", params = {
              issue_id = initiative.issue.id, member_id = active_trustee_id
            }
          }
        elseif not initiative.issue.closed then
          ui.link {
            attr = { class = "btn btn-default" },
            module = "vote", view = "list", 
            params = { issue_id = initiative.issue.id },
            text = _"vote now"
          }
        end
      elseif initiative.member_info.supported then
        ui.container{ content = function()
          ui.tag{ content = _"You are supporter" }
          slot.put(" ")
          if initiative.member_info.satisfied then
            ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "thumb_up" }
          else
            ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "thumb_up" }
          end           
        end }
        if initiative.issue.member_info.own_participation then
          ui.link {
            attr = { class = "btn-link" },
            module = "initiative", action = "remove_support", 
            routing = { default = {
              mode = "redirect", module = "initiative", view = "show", id = initiative.id
            } },
            id = initiative.id,
            text = _"remove my support"
          }
          
        else
          
          ui.link {
            module = "delegation", view = "show", params = {
              issue_id = initiative.issue_id,
              initiative_id = initiative.id
            },
            content = _"via delegation" 
          }
          
        end
        
        slot.put(" ")
        
      end
    end }
    
  end

  if config.initiative_abstract then
    local abstract = string.match(initiative.current_draft.content, "(.+)<!%--END_OF_ABSTRACT%-->")
    if abstract then
      ui.container{
        attr = { class = "abstract", style = "padding-right: 140px;" },
        content = function() slot.put(abstract) end
      }
    end
  end
  
  ui.container { attr = { class = "support" }, content = function ()
    
    if not config.voting_only then
      execute.view {
        module = "initiative", view = "_bargraph", params = {
          initiative = initiative
        }
      }
      slot.put(" ")

      ui.supporter_count(initiative)
    end
    
  end }
  
end }

execute.view {
  module = "initiative", view = "_sidebar_state",
  params = { initiative = initiative }
}

