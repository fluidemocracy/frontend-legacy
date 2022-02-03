local initiative = param.get("initiative", "table")
local for_event = param.get("for_event", atom.boolean)
local for_member = param.get("for_member", "table")

local issue = initiative.issue

local position = param.get("position", atom.number)

local class = "initiative mdl-list__item-primary-content"
if initiative.rank == 1 then
  class = class .. " rank1"
end
if initiative.revoked then
  class = class .. " revoked"
end

ui.container{
  attr = { class = class },
  content = function ()
    if position == 1 and not for_member and (
      initiative.issue.state == "finished_with_winner" 
      or initiative.issue.state == "finished_without_winner"
    ) then
      util.initiative_pie(initiative)
    end
    ui.container {
      attr = { class = "initiative_name" },
      content = function()
        if initiative.vote_grade ~= nil then
          if initiative.vote_grade > 0 then
            local text = _"voted yes"
            ui.container{ attr = { class = "mdl-list__item-avatar positive" }, content = function()
              ui.tag{ tag = "i", attr = { class = "material-icons", title = text }, content = "thumb_up" }
            end }
          elseif initiative.vote_grade == 0 then
          elseif initiative.vote_grade < 0 then
            local text = _"voted no"
            ui.container{ attr = { class = "mdl-list__item-avatar negative" }, content = function()
              ui.tag{ tag = "i", attr = { class = "material-icons", title = text }, content = "thumb_down" }
            end }
          end
        end
        if not for_member and app.session.member then
          if initiative.member_info.supported then
            if initiative.member_info.satisfied then
              ui.tag{ tag = "i", attr = { id = "lf-initiative__support-" .. initiative.id, class = "material-icons material-icons-small" }, content = "thumb_up" }
              --ui.container { attr = { class = "mdl-tooltip", ["for"] = "lf-initiative__support-" .. initiative.id }, content = _"You are supporter of this initiative" }
            else
              ui.tag{ tag = "i", attr = { id = "lf-initiative__support-" .. initiative.id, class = "material-icons material-icons-small mdl-color-text--orange-500" }, content = "thumb_up" }
              --ui.container { attr = { class = "mdl-tooltip", ["for"] = "lf-initiative__support-" .. initiative.id }, content = _"supporter with restricting suggestions" }
            end 
            slot.put(" ")
          end
        end
        ui.link {
          text = initiative.display_name,
          module = "initiative", view = "show", id = initiative.id
        }
      end
    }
    ui.container{ attr = { class = "mdl-list__item-text-body" }, content = function()
      local draft_content = initiative.current_draft.content
      if config.initiative_abstract then
        local abstract = string.match(draft_content, "(.+)<!%--END_OF_ABSTRACT%-->")
        if abstract then
          slot.put(abstract)
        end
      end
      if not config.voting_only then
        if app.session:has_access("authors_pseudonymous") then
          local initiator_members = initiative:get_reference_selector("initiating_members")
            :add_field("initiator.accepted", "accepted")
            :add_order_by("member.name")
            :add_where("initiator.accepted")
            :exec()

          local initiators = {}
          for i, member in ipairs(initiator_members) do
            if member.accepted then
              initiators[#initiators+1] = member.name
            end
          end
          ui.tag{ content = _"by" }
          slot.put(" ")
          ui.tag{ content = table.concat(initiators, ", ") }
          slot.put("<br />")
        end
      end
      if initiative.rank ~= 1 and (issue.voter_count == nil or issue.voter_count > 0) and not for_event then
        if not config.voting_only or issue.closed then
          execute.view {
            module = "initiative", view = "_bargraph", params = {
              initiative = initiative,
              battled_initiative = issue.initiatives[1]
            }
          }
        
          slot.put(" &nbsp; ")
          
          ui.supporter_count(initiative)
        end
      end
      
      if initiative.positive_votes ~= nil then

        local result_text = ""

        if issue.voter_count == 0 then
          result_text = _("No votes (0)", { result = result })

        elseif initiative.rank == 1 and not for_event then
          local result = ""
          if initiative.eligible then
            result = _("Reached #{sign}#{num}/#{den}", {
              sign = issue.policy.direct_majority_strict and ">" or "≥",
              num = issue.policy.direct_majority_num,
              den = issue.policy.direct_majority_den
            })
          else
            result = _("Failed  #{sign}#{num}/#{den}", {
              sign = issue.policy.direct_majority_strict and ">" or "≥",
              num = issue.policy.direct_majority_num,
              den = issue.policy.direct_majority_den
            })
          end
          local neutral_count = issue.voter_count - initiative.positive_votes - initiative.negative_votes
        
          result_text = _("#{result}: #{yes_count} Yes (#{yes_percent}), #{no_count} No (#{no_percent}), #{neutral_count} Abstention (#{neutral_percent})", {
            result = result,
            yes_count = initiative.positive_votes,
            yes_percent = format.percent_floor(initiative.positive_votes, issue.voter_count),
            neutral_count = neutral_count,
            neutral_percent = format.percent_floor(neutral_count, issue.voter_count),
            no_count = initiative.negative_votes,
            no_percent = format.percent_floor(initiative.negative_votes, issue.voter_count)
          })

        end

        ui.container { attr = { class = "result" }, content = result_text }

      end

    end }
  end
}

if config.attachments and config.attachments.preview_in_listing then

  local file = File:new_selector()
    :left_join("draft_attachment", nil, "draft_attachment.file_id = file.id")
    :add_where{ "draft_attachment.draft_id = ?", initiative.current_draft.id }
    :reset_fields()
    :add_field("file.id")
    :add_field("draft_attachment.title")
    :add_field("draft_attachment.description")
    :add_order_by("draft_attachment.id")
    :limit(1)
    :optional_object_mode()
    :exec()

  if file then
    ui.image{ attr = { class = "attachment" }, module = "file", view = "show.jpg", id = file.id, params = { preview = true } }
  end
end


