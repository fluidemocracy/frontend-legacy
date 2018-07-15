local issue
local area

local issue_id = param.get("issue_id", atom.integer)
if issue_id then
  issue = Issue:new_selector():add_where{"id=?",issue_id}:single_object_mode():exec()
  issue:load_everything_for_member_id(app.session.member_id)
  area = issue.area

else
  local area_id = param.get("area_id", atom.integer)
  area = Area:new_selector():add_where{"id=?",area_id}:single_object_mode():exec()
  area:load_delegation_info_once_for_member_id(app.session.member_id)
end

local polling = param.get("polling", atom.boolean)

local policy_id = param.get("policy_id", atom.integer)
local policy

local preview = param.get("preview")

if #(slot.get_content("error")) > 0 then
  preview = false
end

if policy_id then
  policy = Policy:by_id(policy_id)
end

if issue_id then
  execute.view {
    module = "issue", view = "_head", 
    params = { issue = issue, member = app.session.member }
  }
else
  --[[
  execute.view {
    module = "area", view = "_head", 
    params = { area = area, member = app.session.member }
  }
  --]]
  --[[
  execute.view { 
    module = "initiative", view = "_sidebar_policies", 
    params = {
      area = area,
    }
  }
  --]]
end

ui.form{
  module = "initiative",
  action = "create",
  params = {
    area_id = area.id,
    issue_id = issue and issue.id or nil
  },
  attr = { class = "vertical" },
  content = function()
    ui.grid{ content = function()
      ui.cell_main{ content = function()
        ui.container{ attr = { class = "mdl-card mdl-shadow--2dp mdl-card__fullwidth" }, content = function()
          ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
            if preview then
              ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Preview" }
            elseif issue_id then
              ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"New competing initiative" }
            else
              ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"Create a new issue" }
            end
          end }
            
          ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()

          
            if preview then
              
              ui.section( function()
                ui.sectionHead( function()
                  ui.heading{ level = 1, content = encode.html(param.get("name")) }
                  if not issue then
                    ui.container { content = policy.name }
                  end
                  if param.get("free_timing") then
                    ui.container { content = param.get("free_timing") }
                  end
                  slot.put("<br />")
                  
                  local draft_text = param.get("draft")
                  local draft_text = util.wysihtml_preproc(draft_text)

                  ui.field.hidden{ name = "policy_id", value = param.get("policy_id") }
                  ui.field.hidden{ name = "name", value = param.get("name") }
                  if config.initiative_abstract then
                    ui.field.hidden{ name = "abstract", value = param.get("abstract") }
                    ui.container{
                      attr = { class = "abstract" },
                      content = param.get("abstract")
                    }
                    slot.put("<br />")
                  end
                  ui.field.hidden{ name = "draft", value = draft_text }
                  ui.field.hidden{ name = "free_timing", value = param.get("free_timing") }
                  ui.field.hidden{ name = "polling", value = param.get("polling", atom.boolean) }
                  ui.field.hidden{ name = "location", value = param.get("location") }
                  local formatting_engine
                  if config.enforce_formatting_engine then
                    formatting_engine = config.enforce_formatting_engine
                  else
                    formatting_engine = param.get("formatting_engine")
                  end
                  ui.container{
                    attr = { class = "draft" },
                    content = function()
                      slot.put(draft_text)
                    end
                  }
                  slot.put("<br />")

                  ui.tag{
                    tag = "input",
                    attr = {
                      type = "submit",
                      class = "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--colored",
                      value = _'Publish now'
                    },
                    content = ""
                  }
                  slot.put(" &nbsp; ")
                  ui.tag{
                    tag = "input",
                    attr = {
                      type = "submit",
                      name = "edit",
                      class = "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect",
                      value = _'Edit again'
                    },
                    content = ""
                  }
                  slot.put(" &nbsp; ")
                  local class = "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect"
                  if issue then
                    ui.link{ content = _"Cancel", module = "issue", view = "show", id = issue.id, attr = { class = class } }
                  else
                    ui.link{ content = _"Cancel", module = "index", view = "index", params = { unit = area.unit_id, area = area.id }, attr = { class = class } }
                  end
                end )
              end )
            else
              
              ui.sectionRow( function()
              --[[
                if not preview and not issue_id then
                  ui.container { attr = { class = "section" }, content = _"Before creating a new issue, please check any existant issues before, if the topic is already in discussion." }
                  slot.put("<br />")
                end
              --]]
                if not issue_id then
                  local tmp = { { id = -1, name = "" } }
                  for i, allowed_policy in ipairs(area.allowed_policies) do
                    if not allowed_policy.polling or app.session.member:has_polling_right_for_unit_id(area.unit_id) then
                      tmp[#tmp+1] = allowed_policy
                    end
                  end
                  ui.container{ content = _"Please choose a policy for the new issue:" }
                  ui.field.select{
                    name = "policy_id",
                    foreign_records = tmp,
                    foreign_id = "id",
                    foreign_name = "name",
                    value = param.get("policy_id", atom.integer) or area.default_policy and area.default_policy.id
                  }
                  if policy and policy.free_timeable then
                    local available_timings
                    if config.free_timing and config.free_timing.available_func then
                      available_timings = config.free_timing.available_func(policy)
                      if available_timings == false then
                        slot.put_into("error", "error in free timing config")
                        return false
                      end
                    end
                    ui.heading{ level = 4, content = _"Free timing:" }
                    if available_timings then
                      ui.field.select{
                        name = "free_timing",
                        foreign_records = available_timings,
                        foreign_id = "id",
                        foreign_name = "name",
                        value = param.get("free_timing")
                      }
                    else
                      ui.field.text{
                        name = "free_timing",
                        value = param.get("free_timing")
                      }
                    end
                  end
                end

                if issue and issue.policy.polling and app.session.member:has_polling_right_for_unit_id(area.unit_id) then
                  slot.put("<br />")
                  ui.field.boolean{ name = "polling", label = _"No admission needed", value = polling }
                end
                
                ui.container{ attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label mdl-card__fullwidth" }, content = function ()
                  ui.field.text{
                    attr = { id = "lf-initiative__name", class = "mdl-textfield__input" },
                    label_attr = { class = "mdl-textfield__label", ["for"] = "lf-initiative__name" },
                    label = _"Title",
                    name  = "name",
                    value = param.get("name")
                  }
                end }
                
                if config.initiative_abstract then
                  ui.container { content = _"Enter abstract:" }
                  ui.container{ attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--expandable mdl-textfield__fullwidth" }, content = function()
                    ui.field.text{
                      name = "abstract",
                      multiline = true, 
                      attr = { id = "abstract", style = "height: 20ex; width: 100%;" },
                      value = param.get("abstract")
                    }
                  end }
                end
                
                ui.container { content = _"Enter your proposal and/or reasons:" }
                ui.container{ attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--expandable mdl-textfield__fullwidth" }, content = function()
                  ui.field.wysihtml{
                    name = "draft",
                    multiline = true, 
                    attr = { id = "draft", style = "height: 50ex; width: 100%;" },
                    value = param.get("draft") or config.draft_template
                  }
                end }
                if not issue or issue.state == "admission" or issue.state == "discussion" then
                  ui.container { content = _"You can change your text again anytime during admission and discussion phase" }
                else
                  ui.container { content = _"You cannot change your text again later, because this issue is already in verfication phase!" }
                end
                slot.put("<br />")
                                
                slot.put("<br />")
                ui.tag{
                  tag = "input",
                  attr = {
                    type = "submit",
                    name = "preview",
                    class = "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--colored",
                    value = _'Preview'
                  },
                  content = ""
                }
                slot.put(" &nbsp; ")
                
                local class = "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect"
                if issue then
                  
                  ui.link{ content = _"Cancel", module = "issue", view = "show", id = issue.id, attr = { class = class } }
                else
                  ui.link{ content = _"Cancel", module = "index", view = "index", params = { unit = area.unit_id, area = area.id }, attr = { class = class } }
                end
              end )
            end
          end }
        end }
      end }
      if config.map or config.firstlife then
        ui.cell_sidebar{ content = function()
          ui.container{ attr = { class = "mdl-special-card map mdl-shadow--2dp" }, content = function()
            ui.field.location{ name = "location", value = param.get("location") }
          end }
        end }
      end
    end }
  end
}
