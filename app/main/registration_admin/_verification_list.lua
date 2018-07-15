local verifications = param.get("verifications", "table")

ui.list{
  records = verifications,
  columns = {
    { 
      label = _"Requested at",
      content = function(record)
        ui.link{ module = "registration_admin", view = "verification", id = record.id, content = function()
          ui.container{ content = format.date(record.requested) }
          ui.container{ attr = { class = "light" }, content = format.time(record.requested) }
        end }
      end
    },
    { 
      label = _"Name",
      content = function(record)
        ui.container{ content = function()
          ui.tag{ content = (record.verification_data or record.request_data).name }
          ui.tag{ content = ", " }
          ui.tag{ content = (record.verification_data or record.request_data).first_name }
        end }
      end
    },
    --[[
    { 
      label = _"City",
      content = function(record)
        ui.container{ content = (record.verification_data or record.request_data).zip_code }
        ui.tag{ content = " " }
        ui.tag{ content = (record.verification_data or record.request_data).city }
      end
    },
    --]]
    { 
      label = _"Date/place of birth",
      content = function(record)
        ui.container{ content = (record.verification_data or record.request_data).date_of_birth }
        ui.container{ content = (record.verification_data or record.request_data).place_of_birth }
      end
    },
    { 
      label = _"Fiscal code",
      content = function(record)
        ui.tag{ content = (record.verification_data or record.request_data).fiscal_code }
      end
    },
    { 
      label = _"Contact",
      content = function(record)
        ui.container{ content = function()
          ui.tag{ content = (record.verification_data or record.request_data).email }
        end }
        ui.container{ content = function()
          ui.tag{ content = config.self_registration.sms_prefix }
          local phone_number = (record.verification_data or record.request_data).mobile_phone
          if config.self_registration.sms_strip_leading_zero then
            phone_number = string.match(phone_number, "0(.+)")
          end
          ui.tag{ content = phone_number }
        end }
      end
    }
  }
}

slot.put([[<style>
  
  td {
    vertical-align: top;
  }
  td div.light {
    color: #777;
  }
  
</style>]])
