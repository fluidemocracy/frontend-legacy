ui.heading{ level = 1, content = _"Verification requests" }

if not config.verification or not config.verification.fields then
  return
end


local columns = {}

for i, field in ipairs(config.verification.fields) do
  table.insert(columns, {
    label_attr = { class = "mdl-data-table__cell--non-numeric" },
    field_attr = { class = "mdl-data-table__cell--non-numeric" },
    label = field.label,
    content = function(record)
      ui.tag{ content = record.request_data[field.name] }
    end
  })
end

table.insert(columns, {
  label = _"verified",
  name = "verified"
})

table.insert(columns, {
  label = _"denied",
  name = "denied"
})

table.insert(columns, {
  content = function(record)
    ui.link{ content = _"show", module = "admin", view = "verification", id = record.id }
  end
})

local new_verifications = Verification:new_selector():add_where("verified ISNULL and denied ISNULL"):exec()
local verified_verifications = Verification:new_selector():add_where("verified NOTNULL"):exec()
local denied_verifications = Verification:new_selector():add_where("denied NOTNULL"):exec()

ui.container{ attr = { class = "mdl-tabs mdl-js-tabs mdl-js-ripple-effect" }, content = function()
  ui.container{ attr = { class = "mdl-tabs__tab-bar" }, content = function()
    ui.link{ content = _"new requests", external = "#new_requests", attr = { class = "mdl-tabs__tab is-active" } }
    ui.link{ content = _"verified", external = "#verified", attr = { class = "mdl-tabs__tab" } }
    ui.link{ content = _"denied", external = "#denied", attr = { class = "mdl-tabs__tab" } }
  end }
  slot.put("<br />")
  ui.container{ attr = { class = "mdl-tabs__panel is-active", id = "new_requests" }, content = function()
    ui.list{
      records = new_verifications,
      attr = { class = "mdl-data-table mdl-js-data-table mdl-shadow--2dp" },
      columns = columns
    }
  end }
  ui.container{ attr = { class = "mdl-tabs__panel", id = "verified" }, content = function()
    ui.list{
      records = verified_verifications,
      attr = { class = "mdl-data-table mdl-js-data-table mdl-shadow--2dp" },
      columns = columns
    }
  end }
  ui.container{ attr = { class = "mdl-tabs__panel", id = "denied" }, content = function()
    ui.list{
      records = denied_verifications,
      attr = { class = "mdl-data-table mdl-js-data-table mdl-shadow--2dp" },
      columns = columns
    }
  end }
end }

