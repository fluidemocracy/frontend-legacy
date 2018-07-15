local verifications = param.get("verifications", "table")

local columns = {
  { 
    label = _"Requested at",
    content = function(record)
      ui.link{ module = "registration_admin", view = "role_verification", id = record.id, content = function()
        ui.container{ content = format.date(record.requested) }
        ui.container{ attr = { class = "light" }, content = format.time(record.requested) }
      end }
    end
  }
}

for i, field in ipairs(config.role_registration.fields) do
  table.insert(columns, {
    label = field.label,
    content = function(record)
      ui.tag{ content = record.request_data[field.name] }
    end
  })
end

ui.list{
  records = verifications,
  columns = columns
}

slot.put([[<style>
  
  td {
    vertical-align: top;
  }
  td div.light {
    color: #777;
  }
  
</style>]])
