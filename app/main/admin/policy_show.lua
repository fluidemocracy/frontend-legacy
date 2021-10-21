local function field(name, label, value, tooltip)
  ui.field.text{
    container_attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label" },
    attr = { id = "field_" .. name, class = "mdl-textfield__input" },
    label_attr = { class = "mdl-textfield__label", ["for"] = "field_" .. name },
    label = label,
    name = name,
    value = value or nil
  }
  if tooltip then
    ui.container{ attr = { class = "mdl-tooltip", ["for"] = "field_" .. name }, content = tooltip }
  end
end

local function rational_field(name, label, value_num, value_den, tooltip)

  ui.container{
    attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label" },
    content = function()
      ui.tag{
        attr = { class = "mdl-textfield__label", ["for"] = "field_" .. name },
        content = label
      }
      ui.field.text{
        container_attr = { style = "display: inline-block;" },
        attr = { style = "width: 3em;", id = "field_" .. name .. "_num", class = "mdl-textfield__input" },
        name = name .. "_num",
        value = value_num or nil
      }
      slot.put(" / ")
      ui.field.text{
        container_attr = { style = "display: inline-block;" },
        attr = { style = "width: 3em;", id = "field_" .. name .. "_den", class = "mdl-textfield__input" },
        name = name .. "_den",
        value = value_den or nil
      }
    end
  }
  if tooltip then
    ui.container{ attr = { class = "mdl-tooltip", ["for"] = "field_" .. name .. "_num" }, content = tooltip }
    ui.container{ attr = { class = "mdl-tooltip", ["for"] = "field_" .. name .. "_den" }, content = tooltip }
  end
end

local function majority_field(name, label, value_num, value_den, strict, tooltip)

  ui.container{
    attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label" },
    content = function()
      ui.tag{
        attr = { class = "mdl-textfield__label", ["for"] = "field_" .. name },
        content = label
      }
      ui.tag{ tag = "select", attr = { name = name .. "_strict" }, content = function()
        ui.tag{ tag = "option", attr = { value = "0", selected = not strict and "selected" or nil }, content = "≥" }
        ui.tag{ tag = "option", attr = { value = "1", selected = strict and "selected" or nil }, content = ">" }
      end }
      slot.put(" ")
      ui.field.text{
        container_attr = { style = "display: inline-block;" },
        attr = { style = "width: 3em;", id = "field_" .. name .. "_num", class = "mdl-textfield__input" },
        name = name .. "_num",
        value = value_num or nil
      }
      slot.put(" / ")
      ui.field.text{
        container_attr = { style = "display: inline-block;" },
        attr = { style = "width: 3em;", id = "field_" .. name .. "_den", class = "mdl-textfield__input" },
        name = name .. "_den",
        value = value_den or nil
      }
    end
  }
  if tooltip then
    ui.container{ attr = { class = "mdl-tooltip", ["for"] = "field_" .. name .. "_num" }, content = tooltip }
    ui.container{ attr = { class = "mdl-tooltip", ["for"] = "field_" .. name .. "_den" }, content = tooltip }
  end
end


local policy = Policy:by_id(param.get_id()) or Policy:new()

local hint = not policy.id

ui.titleAdmin(_"Policy")

ui.grid{ content = function()

  ui.cell_main{ content = function()
    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = policy and policy.name or _"New policy" }
      end }
      ui.container{ attr = { class = "mdl-card__content" }, content = function()
        ui.form{
          attr = { class = "vertical" },
          record = policy,
          module = "admin",
          action = "policy_update",
          routing = {
            default = {
              mode = "redirect",
              module = "admin",
              view = "index"
            }
          },
          id = policy.id,
          content = function()

            field("index", _"Index (for sorting)", hint and "1" or nil)
            ui.field.boolean{ label = _"Active?", name = "active", value = hint and true or nil }

            field("name", _"Name")
          
            ui.field.text{ label = _"Description", name = "description", multiline = true }
            ui.field.text{ label = "",        readonly = true, 
                            value = _"Interval format:" .. " 3 mons 2 weeks 1 day 10:30:15" }

                            
            ui.heading{ level = 5, content = _"Admission phase" }
            field("min_admission_time", _"Minimum admission time", hint and "0" or nil, _"Minimum time an issue has to stay in admission phase before it can be accepted for discussion (if it reaches the 1st quorum).")
            field("max_admission_time", _"Maximum admission time", hint and "30 days" or nil, _"Maximum time within which an issue has to reach the 1st quorum, otherwise it will be canceled.")
            ui.field.boolean{ attr = { id = "field_polling" }, label = _"Polling mode", name = "polling", value = hint and false or nil }
            ui.container{ attr = { class = "mdl-tooltip", ["for"] = "field_polling" }, content = _"Skip admission phase and start issue in discussion phase (can only be started by members with polling privilege). If enabled, minimum and maximum admission time as well as 1st quorum needs to be cleared." }
                            
            ui.heading{ level = 5, content = _"First quorum" }
            ui.container{ content = _"Minimum supporter count (including support via delegation) one initiative of an issue has to reach to let the issue pass the 1st quorum and to proceed to discussion phase. Further requirements can occur due to per subject area issue limiter settings. See subject area settings." }
            field("issue_quorum", _"Absolute issue quorum", hint and "1" or nil, _"Minimum absolute number of supporters.")
            rational_field("issue_quorum", "Relative issue quorum", hint and "1" or nil, hint and "100" or nil, _"Minimum number of supporters relative to the number of active participants in the organizational unit.")

            ui.heading{ level = 5, content = _"Discussion phase" }
            field("discussion_time", _"Discussion time", hint and "30 days" or nil, _"Duration of discussion phase of an issue.")
            
            ui.heading{ level = 5, content = _"Verification phase" }
            field("verification_time", _"Verfication time", hint and "7 days" or nil, _"Duration of verification phase of an issue.")
            
            ui.heading{ level = 5, content = _"Second quorum" }
            ui.container{ content = _"Minimum supporter count (including support via delegation) an initiative has to reach to be an eligible candidate for the voting phase." }
            field("initiative_quorum", _"Absolute initiative quorum", hint and "1" or nil, _"Minimum absolute number of supporters.")
            rational_field("initiative_quorum", "Relative initiative quorum", hint and "1" or nil, hint and "100" or nil, _"Minimum number of supporters relative to the number of active participants in the organizational unit.")

            ui.heading{ level = 5, content = _"Voting phase" }
            field("voting_time", _"Voting time", hint and "15 days" or nil, _"Duration of voting phase of an issue.")

            ui.heading{ level = 5, content = _"Required majorities" }
            majority_field("direct_majority", _"Majority", hint and "50" or nil, hint and "100" or nil, policy.direct_majority_strict, "The required majority of approval votes relative to the sum of approval and disapproval votes for the same initiative.")
            field("direct_majority_positive", _"Absolute number of approval votes", hint and "0" or nil, _"The minimum absolute number of approval votes.")
            field("direct_majority_non_negative", _"Absolute number of approval and abstention votes", hint and "0" or nil, _"The minimum absolute number of approval votes.")

            ui.heading{ level = 5, content = _"Experimental features" }
            ui.container{ content = _"The following settings for experimental features should only be changed with sufficient knowledge about the Schulze method and its implementation in LiquidFeedback." }
            ui.field.text{ label = _"Indirect majority numerator",   name = "indirect_majority_num", value = hint and "50" or nil }
            ui.field.text{ label = _"Indirect majority denominator", name = "indirect_majority_den", value = hint and "100" or nil }
            ui.field.boolean{ label = _"Strict indirect majority", name = "indirect_majority_strict", value = hint and true or nil }
            ui.field.text{ label = _"Indirect majority positive",   name = "indirect_majority_positive", value = hint and "0" or nil }
            ui.field.text{ label = _"Indirect majority non negative", name = "indirect_majority_non_negative", value = hint and "0" or nil }

            ui.field.boolean{ label = _"No reverse beat path", name = "no_reverse_beat_path", value = hint and false or nil }
            ui.field.boolean{ label = _"No multistage majority", name = "no_multistage_majority", value = hint and false or nil }

            slot.put("<br />")

            ui.submit{ 
              attr = { class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect" },
              text = _"update policy" 
            }
            slot.put(" ")
            ui.link { 
              attr = { class = "mdl-button mdl-js-button" },
              module = "admin", view = "index", content = _"cancel" 
            }
          end
        }
      end }
    end }
  end }
end }
