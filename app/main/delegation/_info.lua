if not app.session.member_id then
  return
end

local member = param.get("member", "table") or app.session.member

local unit  = param.get("unit", "table")
local area  = param.get("area", "table")
local issue = param.get("issue", "table")

local for_title = param.get("for_title", "boolean")

local unit_id  = unit  and unit.id  or nil
local area_id  = area  and area.id  or nil
local issue_id = issue and issue.id or nil

local info
local delegation_text

if unit then
  info = unit.delegation_info
  delegation_text = _"Delegate unit"
end

if area then
  info = area.delegation_info
  delegation_text = _"Delegate area"
end

if issue then
  info = issue.member_info
  delegation_text = _"Delegate issue"
end

if not info then
  --return
end

local function print_delegation_info()
  local participant_occured = info.own_participation
  
  if not (issue and issue.state == "voting" and info.own_participation) then
    
    if info.first_trustee_id then
    
      local text = _"delegates to"
      ui.image{
        attr = { class = "delegation_arrow", alt = text, title = text },
        static = "delegation_arrow_24_horizontal.png"
      }

      local class = "micro_avatar"
      if not participant_occured and info.first_trustee_participation then
        participant_occured = true
        class = class .. " highlighted"
      end
      
      execute.view{ module = "member_image", view = "_show", params = {
        member_id = info.first_trustee_id, class = class, popup_text = info.first_trustee_name,
        image_type = "avatar", show_dummy = true,
      } }

    end
          
    if info.first_trustee_ellipsis then

      local text = _"delegates to"
      ui.image{
        attr = { class = "delegation_arrow", alt = text, title = text },
        static = "delegation_arrow_24_horizontal.png"
      }

      slot.put("...")
      
    end
    
    if info.other_trustee_id then
    
      local text = _"delegates to"
      ui.image{
        attr = { class = "delegation_arrow", alt = text, title = text },
        static = "delegation_arrow_24_horizontal.png"
      }

      local class = "micro_avatar"
      if not participant_occured and info.other_trustee_participation then
        participant_occured = true
        class = class .. " highlighted"
      end
      
      execute.view{ module = "member_image", view = "_show", params = {
        member_id = info.other_trustee_id, class = class, popup_text = info.other_trustee_name,
        image_type = "avatar", show_dummy = true,
      } }

    end
          
    if info.other_trustee_ellipsis then

      local text = _"delegates to"
      ui.image{
        attr = { class = "delegation_arrow", alt = text, title = text },
        static = "delegation_arrow_24_horizontal.png"
      }

      slot.put("...")
      
    end
    
    local trailing_ellipsis = info.other_trustee_ellipsis or
      (info.first_trustee_ellipsis and not info.other_trustee_id)
    
    if info.delegation_loop == "own" then
      
      local text = _"delegates to"
      ui.image{
        attr = { class = "delegation_arrow", alt = text, title = text },
        static = "delegation_arrow_24_horizontal.png"
      }

      execute.view{ module = "member_image", view = "_show", params = {
        member = member, class = "micro_avatar", popup_text = member.name,
        image_type = "avatar", show_dummy = true,
      } }

    elseif info.delegation_loop == "first" then
      if info.first_trustee_ellipsis then
        if not trailing_ellipsis then

          local text = _"delegates to"
          ui.image{
            attr = { class = "delegation_arrow", alt = text, title = text },
            static = "delegation_arrow_24_horizontal.png"
          }

          slot.put("...")
        end
          
      else
          
        local text = _"delegates to"
        ui.image{
          attr = { class = "delegation_arrow", alt = text, title = text },
          static = "delegation_arrow_24_horizontal.png"
        }

        execute.view{
          module = "member_image", view = "_show", params = {
            member_id = info.first_trustee_id, 
            class = "micro_avatar", 
            popup_text = info.first_trustee_name,
            image_type = "avatar",
            show_dummy = true,
          }
        }
      end
    
        
    elseif info.delegation_loop and not trailing_ellipsis then
      local text = _"delegates to"
      ui.image{
        attr = { class = "delegation_arrow", alt = text, title = text },
        static = "delegation_arrow_24_horizontal.png"
      }

      slot.put("...")
    end

  end
end

if not param.get("no_star", "boolean") and issue then
  local redirect_unit = request.get_param{ name = "unit" }
  local redirect_area = request.get_param{ name = "area" }

  if issue.fully_frozen and info.own_participation then
    ui.link{
      attr = { class = "mdl-button mdl-js-button mdl-js-ripple-effect mdl-button--underlined" },
      module = "vote", view = "list", params = {
        issue_id = issue.id
      },
      content = function ()
        ui.tag { content = _"you voted" }
      end
    }
  elseif not issue.half_frozen and not issue.closed and not info.own_participation then
    ui.link{
      attr = {
        id = "issue_" .. issue.id .. "_interest_link",
        class = "float-right mdl-button mdl-js-button mdl-button--icon mdl-button--feature-off",
      },
      form_attr = {
        onsubmit = "toggleInterest(" .. issue.id .. ", 'issue_" .. issue.id .. "_interest_icon'); return false;"  
      },
      module = "interest", action = "update", params = { issue_id = issue.id, interested = true },
      routing = { default = {
        mode = "redirect", module = "index", view = "index", params = {
          unit = redirect_unit, area = redirect_area
        },
        anchor = "issue_" .. issue.id
      } },
      content = function()
        ui.tag{ tag = "i", attr = { id = "issue_" .. issue.id .. "_interest_icon", class = "material-icons" }, content = "star_outline" }
      end
    }
  elseif not issue.half_frozen and not issue.closed and info.own_participation then
    ui.link{
      attr = {
        id = "issue_" .. issue.id .. "_interest_link",
        class = "float-right mdl-button mdl-js-button mdl-button--icon mdl-button--accent"
      },
      form_attr = {
        onsubmit = "toggleInterest(" .. issue.id .. ", 'issue_" .. issue.id .. "_interest_icon'); return false;"  
      },
      module = "interest", action = "update", params = { issue_id = issue.id, interested = false },
      routing = { default = {
        mode = "redirect", module = "index", view = "index", params = {
          unit = redirect_unit, area = redirect_area
        },
        anchor = "issue_" .. issue.id
      } },
      content = function()
        ui.tag{ tag = "i", attr = { id = "issue_" .. issue.id .. "_interest_icon", class = "material-icons" }, content = "star" }
      end
    }

    local privilege = Privilege:new_selector()
      :add_where{ "member_id = ?", member.id }
      :add_where{ "unit_id = ?", issue.area.unit_id }
      :optional_object_mode()
      :exec()

    local own_weight = privilege and privilege.weight or 0

    if not issue.closed and info.own_participation and info.weight and info.weight > own_weight then
      local weight = info.weight - own_weight
      if config.token and config.token.unit_id == issue.area.unit_id then
        weight = weight / 100 .. " " .. config.token.token_name
      end
      slot.put(" ")
      ui.link { 
        attr = { class = "right" }, content = "+" .. weight,
        module = "interest", view = "show_incoming", params = { 
          issue_id = issue.id, member_id = member.id
        }
      }
    end
    slot.put(" ")
  end
end


if info.own_participation or info.first_trustee_id then
  local class = "delegation_info"
  if info.own_participation then
    class = class .. " suspended"
  end

  local voting_member_id
  local voting_member_name
  if issue and issue.fully_frozen and issue.closed then
    if issue.member_info.first_trustee_participation then
      voting_member_id = issue.member_info.first_trustee_id
      voting_member_name = issue.member_info.first_trustee_name
    elseif issue.member_info.other_trustee_participation then
      voting_member_id = issue.member_info.other_trustee_id
      voting_member_name = issue.member_info.other_trustee_name
    end
  end
  
  if app.session.member_id == member.id then

    if voting_member_id  then
      ui.link{
        module = "vote", view = "list", params = {
          issue_id = issue.id,
          member_id = voting_member_id
        },
        attr = { class = class }, content = function()
          print_delegation_info()
        end
      }
    
    else
      ui.link{
        module = "delegation", view = "show", params = {
          unit_id = unit_id,
          area_id = area_id,
          issue_id = issue_id
        },
        attr = { class = class }, content = function()
          print_delegation_info()
        end
      }
    end
  else
    ui.container{
      attr = { class = class }, content = function()
        print_delegation_info()
      end
    }
  end
end

if issue and app.session.member and issue.fully_frozen and not issue.closed and not issue.member_info.direct_voted and app.session.member:has_voting_right_for_unit_id(issue.area.unit_id) then
    ui.link{
      attr = { class = "mdl-button mdl-js-button mdl-js-ripple-effect mdl-button--underlined" },
      module = "vote", view = "list", params = {
        issue_id = issue.id
      },
      content = function ()
        ui.tag { content = _"vote now" }
      end
    }
  else
end
