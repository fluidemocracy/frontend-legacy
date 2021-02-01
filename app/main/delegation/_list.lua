local delegations_selector = param.get("delegations_selector", "table")
local outgoing = param.get("outgoing", atom.boolean)
local incoming = param.get("incoming", atom.boolean)

local function delegation_scope(delegation)
  ui.tag{
    attr = { class = "delegation_scope" },
    content = function()
      local area
      local unit
      if delegation.issue then
        area = delegation.issue.area
        unit = area.unit
      elseif delegation.area then
        area = delegation.area
        unit = area.unit
      else
        unit = delegation.unit
      end
      slot.put("<br style='clear: left;' />")
      ui.container { attr = { style = "float: left;" }, content = function()
        ui.link{
          content = unit.name,
          module = "index",
          view = "index",
          params = { unit = unit.id }
        }
        if area then
          slot.put(" &middot; ")
          ui.link{
            content = area.name,
            module = "index",
            view = "index",
            params = { unit = area.unit_id, area = area.id }
          }
        end
        if delegation.issue then
          slot.put(" &middot; ")
          ui.link{
            content = delegation.issue.name,
            module = "issue",
            view = "show",
            id = delegation.issue.id
          }
        end
      end }
    end
  }
end

local last_scope = {}
for i, delegation in ipairs(delegations_selector:exec()) do
  if last_scope.unit_id ~= delegation.unit_id
    or last_scope.area_id ~= delegation.area_id
    or last_scope.issue_id ~= delegation.issue_id
  then
    last_scope.unit_id = delegation.unit_id
    last_scope.area_id = delegation.area_id
    last_scope.issue_id = delegation.issue_id
    delegation_scope(delegation)
  end
  if incoming then
    execute.view{
      module = "member",
      view = "_show_thumb",
      params = {
        member = delegation.truster
      }
    }
  elseif delegation.trustee then
    ui.image{
      attr = { class = "delegation_arrow" },
      static = "delegation_arrow_24_horizontal.png"
    }
    execute.view{
      module = "member",
      view = "_show_thumb",
      params = {
        member = delegation.trustee
      }
    }
  else
    ui.tag{ content = _"Delegation abandoned" }
  end
end

