local verification = Verification:by_id(param.get_id())

local data = {}

for i, field in ipairs(config.verification.fields) do
  table.insert(data, {
    label = field.label,
    value = verification.request_data[field.name]
  })
end

table.insert(data, {
  label = _"IP address",
  value = verification.request_origin.ip
})

table.insert(data, {
  label = _"Hostname",
  value = verification.request_origin.hostname
})

if verification.verified then
  table.insert(data, {
    label = _"Requested at",
    value = format.timestamp(verification.requested)
  })
end

if verification.requesting_member_id then
  table.insert(data, {
    label = _"Requested by account",
    value = verification.requesting_member_id
  })
end

if verification.verified then
  table.insert(data, {
    label = _"Verified at",
    value = format.timestamp(verification.verified)
  })
end

if verification.denied then
  table.insert(data, {
    label = _"Denied at",
    value = format.timestamp(verification.denied)
  })
end

if verification.verifying_member_id then
  table.insert(data, {
    label = _"Verified by account",
    value = verification.verifying_member_id
  })
end

if verification.comment then
  table.insert(data, {
    label = _"Comment",
    value = verification.comment
  })
end

if verification.verified_member_id then
  table.insert(data, {
    label = _"Used by account",
    value = verification.veried_member_id
  })
end

ui.container{ attr = { class = "mdl-cell mdl-cell--12-col" }, content = function()
  ui.list{
    attr = { class = "mdl-data-table mdl-js-data-table mdl-shadow--2dp" },
    records = data,
    columns = {
      {
        label_attr = { class = "mdl-data-table__cell--non-numeric" },
        field_attr = { class = "mdl-data-table__cell--non-numeric" },
        label = _"Field",
        content = function(record)
          ui.tag{ content = record.label }
        end
      },
      {
        label_attr = { class = "mdl-data-table__cell--non-numeric" },
        field_attr = { class = "mdl-data-table__cell--non-numeric" },
        label = _"Value",
        content = function(record)
          ui.tag{ content = record.value }
        end
      },
    }
  }
end }

if not verification.verification_data and not verification.denied then
  ui.form{
    module = "admin", action = "verification_update", id = verification.id,
    record = verification,
    content = function()
      ui.field.text{ 
        container_attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label" },
        attr = { id = "lf-verification_data", class = "mdl-textfield__input" },
        label = _"Verification data",
        name = "verification_data"
      }
      slot.put("<br /><br />")
      ui.tag{
        tag = "input",
        attr = {
          type = "submit",
          class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored",
          value = _"Verify account"
        }
      }
      slot.put(" &nbsp; ")
      ui.tag{
        tag = "input",
        attr = {
          type = "submit",
          name = "deny",
          class = "mdl-button mdl-js-button mdl-button--raised mdl-button--accent",
          value = _"Deny request"
        }
      }
      slot.put(" &nbsp; ")
      ui.link{ 
        attr = { class = "mdl-button mdl-js-button mdl-button--raised" },
        content = _"Cancel", 
        module = "admin", view = "verification_list"
      }
    end
  }
end
