local initiator = param.get("initiator", "table")
local member = param.get("member", "table")

local issue = param.get("issue", "table")
local initiative = param.get("initiative", "table")
local trustee = param.get("trustee", "table")

local class = param.get("class")

local name_html
if member.name_highlighted then
  name_html = encode.highlight(member.name_highlighted)
else
  name_html = encode.html(member.name)
end

local container_class = "mdl-chip mdl-chip--contact clickable mdl-badge mdl-badge--overlap"
if initiator and member.accepted ~= true then
  container_class = container_class .. " not_accepted"
end

if member.is_informed == false then
  container_class = container_class .. " not_informed"
end

if class then
  container_class = container_class .. " " .. class
end

local in_delegation_chain = member.in_delegation_chain
--[[if member.delegate_member_ids then
  for member_id in member.delegate_member_ids:gmatch("(%w+)") do
    if tonumber(member_id) == member.id then
      in_delegation_chain = true
    end
  end
end
--]]
if in_delegation_chain or ((issue or initiative) and member.id == app.session.member_id) then
  container_class = container_class .. " in_delegation_chain"
end

local el_id = multirand.string(32, "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
local weight = 0
local ownweight = member.ownweight
if member.weight then
  weight = member.weight
end
if member.voter_weight then
  weight = member.voter_weight
end
local delegated_weight = weight - (ownweight or 0)

local weight_text = ""

if ownweight and ownweight > 1 then
  weight_text = weight_text .. ownweight
end

if delegated_weight > 0 then
  weight_text = weight_text .. "+" .. delegated_weight
end

if weight_text == "" then
  weight_text = nil
end

ui.container{
  attr = { id = el_id, class = container_class },
  content = function()

    execute.view{
      module = "member_image",
      view = "_show",
      params = {
        member = member,
        image_type = "avatar",
        show_dummy = true
      }
    }
    ui.tag{
      attr = { class = "mdl-chip__text" },
      content = function() 
        slot.put(name_html)
        if weight_text then
          slot.put(" ")
          ui.tag{ attr = { class = "member_weight" }, content = weight_text }
        end
      end
    }
    
    if member.grade then
      slot.put ( " " )
      if member.grade > 0 then
        ui.tag{ tag = "i", attr = { class = "material-icons icon-green" }, content = "thumb_up" }
      elseif member.grade < 0 then
        ui.tag{ tag = "i", attr = { class = "material-icons icon-red" }, content = "thumb_down" }
      else
        ui.tag{ tag = "i", attr = { class = "material-icons icon-yellow" }, content = "brightness_1" }
      end
    end

    if (member.voter_comment) then
      local text = _"Voting comment available",
      ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "comment" }
    end


    if (issue or initiative) and weight > 0 then
    end
    
    if member.supporter then
      ui.tag { attr = { class = "mdl-chip__action" }, content = function()
        if member.supporter_satisfied then
          local text = _"supporter"
          ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "thumb_up" }
        else
          local text = _"supporter with restricting suggestions"
          ui.tag{ tag = "i", attr = { class = "material-icons mdl-color-text--orange-900" }, content = "thumb_up" }
        end
      end }
    end

    if not member.active then
      local text = _"member inactive"
      ui.tag{ tag = "i", attr = { class = "material-icons icon-red" }, content = "disabled_by_default" }
    end

    if initiator and initiator.accepted then
      if member.accepted == nil then
        slot.put(_"Invited [as initiator]")
      elseif member.accepted == false then
        slot.put(_"Rejected [initiator invitation]")
      end
    end

    if member.is_informed == false then
      local text = _"Member has not approved latest draft"
      ui.tag{ tag = "i", attr = { class = "material-icons icon-yellow" }, content = "help" }
    end

  end
}

if member.grade or (issue and weight > 1) or app.session.member_id or app.session:has_access("everything") then
  ui.tag { tag = "ul", attr = { class = "mdl-menu mdl-menu--bottom-left mdl-js-menu mdl-js-ripple-effect", ["for"] = el_id }, content = function()
    if (member.grade) then
      ui.tag{ tag = "li", attr = { class = "mdl-menu__item" }, content = function()
        ui.link{
          attr = { class = "mdl-menu__link" },
          module = "vote",
          view = "list",
          params = {
            issue_id = issue.id,
            member_id = member.id,
          },
          content = _"show ballot"
        }
      end }
    end
    if issue and weight > 1 then
      ui.tag{ tag = "li", attr = { class = "mdl-menu__item" }, content = function()
        local module = "interest"
        if member.voter_weight then
          module = "vote"
        end
        ui.link{ attr = { class = "mdl-menu__link" }, content = _"show incoming delegations", module = module, view = "show_incoming", params = {
          member_id = member.id, 
          initiative_id = initiative and initiative.id or nil,
          issue_id = issue and issue.id or nil
        } }
      end }
    end
    if app.session:has_access("everything") then
      ui.tag{ tag = "li", attr = { class = "mdl-menu__item" }, content = function()
        ui.link{ attr = { class = "mdl-menu__link" }, content = _"show profile", module = "member", view = "show", id = member.id }
      end }
    end
    if app.session.member_id and app.session.member_id ~= member.id then
      ui.tag{ tag = "li", attr = { class = "mdl-menu__item" }, content = function()
        ui.link{
          attr = { class = "mdl-menu__link" },
          text    = _"add to my list of private contacts",
          module  = "contact",
          action  = "add_member",
          id      = member.id,
          routing = {
            default = {
              mode = "redirect",
              module = request.get_module(),
              view = request.get_view(),
              id = request.get_id_string(),
              params = request.get_param_strings(),
              anchor = "member_list"
            }
          }
        }
      end }
    end  
  end }
end
