local member = Member:by_id(param.get_id())

if not member or not member.activated then
  execute.view { module = "index", view = "404" }
  request.set_status("404 Not Found")
  return
end

local limit = 25

local initiated_initiatives = Initiative:new_selector()
  :join("initiator", nil, { "initiator.initiative_id = initiative.id and initiator.member_id = ?", member.id })
  :join("issue", nil, "issue.id = initiative.issue_id")
  :add_order_by("initiative.id DESC")
  :limit(limit+1)
  :exec()
  
initiated_initiatives:load("issue")
initiated_initiatives:load_everything_for_member_id(member.id)

local supported_initiatives = Initiative:new_selector()
  :join("supporter", nil, { "supporter.initiative_id = initiative.id and supporter.member_id = ?", member.id })
  :join("issue", nil, "issue.id = initiative.issue_id")
  :add_where("issue.closed ISNULL")
  :add_order_by("initiative.id DESC")
  :limit(limit+1)
  :exec()

supported_initiatives:load("issue")
supported_initiatives:load_everything_for_member_id(member.id)

local voted_initiatives = Initiative:new_selector()
  :add_where("initiative.rank = 1")
  :join("direct_voter", nil, { "direct_voter.issue_id = initiative.issue_id and direct_voter.member_id = ?", member.id })
  :join("vote", nil, { "vote.initiative_id = initiative.id and vote.member_id = ?", member.id })
  :join("issue", nil, "issue.id = initiative.issue_id")
  :add_order_by("issue.closed DESC, initiative.id DESC")
  :add_field("vote.grade", "vote_grade")
  :add_field("vote.first_preference", "vote_first_preference")
  :limit(limit+1)
  :exec()

voted_initiatives:load("issue")
voted_initiatives:load_everything_for_member_id(member.id)
  
local incoming_delegations_selector = member:get_reference_selector("incoming_delegations")
  :left_join("issue", "_member_showtab_issue", "_member_showtab_issue.id = delegation.issue_id AND _member_showtab_issue.closed ISNULL")
  :add_where("_member_showtab_issue.closed ISNULL")
  :add_order_by("delegation.unit_id, delegation.area_id, delegation.issue_id")
  :limit(limit+1)

local outgoing_delegations_selector = member:get_reference_selector("outgoing_delegations")
  :left_join("issue", "_member_showtab_issue", "_member_showtab_issue.id = delegation.issue_id AND _member_showtab_issue.closed ISNULL")
  :add_where("_member_showtab_issue.closed ISNULL")
  :add_order_by("delegation.unit_id, delegation.area_id, delegation.issue_id")
  :limit(limit+1)


app.html_title.title = member.name
app.html_title.subtitle = _("Member")

ui.titleMember(member)

ui.grid{ content = function()
  ui.cell_main{ content = function()
    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = function()
          execute.view{
            module = "member_image",
            view = "_show",
            params = {
              member = member,
              image_type = "avatar",
              show_dummy = true,
              class = "left",
              force_update = app.session.member_id == member.id
            }
          }
          slot.put(" ")
          ui.tag{ content = member.name }
        end }
        ui.container {
          attr = { class = "float-right" },
          content = function()
            ui.link{
              content = _"Account history",
              module = "member", view = "history", id = member.id
            }
          end
        }
      end }
      
      ui.container{ attr = { class = "mdl-card__content" }, content = function()

        if member.identification then
          ui.container{ content = member.identification }
        end

        execute.view{
          module = "member",
          view = "_profile",
          params = { member = member }
        }

        --[[
        execute.view {
          module = "member", view = "_timeline",
          params = { member = member }
        }
        --]]
      end }
    end }
    
    if #initiated_initiatives > 0 then
      ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
        ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
          ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Initiatives created by this member" }
        end }
        ui.container{ attr = { class = "initiative_list" }, content = function()
          execute.view {
            module = "initiative", view = "_list",
            params = { initiatives = initiated_initiatives, for_member = member },
          }
        end }
      end }
    end
    
    if #supported_initiatives > 0 then
      ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
        ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
          ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"What this member is currently supporting" }
        end }
        ui.container{ attr = { class = "initiative_list" }, content = function()
          execute.view {
            module = "initiative", view = "_list",
            params = { initiatives = supported_initiatives, for_member = member },
          }
        end }
      end }
    end
    
    if #voted_initiatives > 0 then
      ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
        ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
          ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"How this member voted" }
        end }
        ui.container{ attr = { class = "initiative_list" }, content = function()
          execute.view {
            module = "initiative", view = "_list",
            params = { initiatives = voted_initiatives, for_member = member },
          }
        end }
      end }
    end
    --[[
    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Outgoing delegations" }
      end }
      ui.container{ attr = { class = "mdl-card__content" }, content = function()
        execute.view {
          module = "delegation", view = "_list",
          params = { delegations_selector = outgoing_delegations_selector, outgoing = true },
        }
      end }
    end }

    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Incoming delegations" }
      end }
      ui.container{ attr = { class = "mdl-card__content" }, content = function()
        execute.view {
          module = "delegation", view = "_list",
          params = { delegations_selector = incoming_delegations_selector, incoming = true },
        }
      end }
    end }
    --]]
  end }
    
  ui.cell_sidebar{ content = function()
    execute.view {
      module = "member", view = "_sidebar_whatcanido", params = {
        member = member
      }
    }

    execute.view {
      module = "member", view = "_sidebar_contacts", params = {
        member = member
      }
    }
  end }

end }

if app.session.member_id == member.id then
  ui.script{ script = [[
    var url = $(".microAvatar")[0].src;
    var onload = function() {
      this.contentWindow.location.reload(true);
      this.removeEventListener("load", onload, false);
      this.parentElement.removeChild(this);
    }
    var iframeEl = document.createElement("iframe");
    iframeEl.style.display = "none";
    iframeEl.src = url;
    iframeEl.addEventListener("load", onload, false);
    document.body.appendChild(iframeEl);
  ]] }
end
