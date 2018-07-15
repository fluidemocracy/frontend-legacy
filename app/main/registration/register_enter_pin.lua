local id = param.get_id()
local verification = Verification:by_id(id)
local invalid_pin = param.get("invalid_pin", atom.boolean)

ui.title(_"Self registration")
app.html_title.title = _"Self registration"

ui.container{ attr = { class = "mdl-grid" }, content = function()
  ui.container{ attr = { class = "mdl-cell mdl-cell--12-col" }, content = function()

    ui.heading{ content = _"PIN page" }
    slot.put("<br />")
    ui.container { content = _"You should receive a PIN code via SMS shortly. Please enter the PIN." }
    
    if invalid_pin then
      slot.put("<br />")
      ui.container { attr = { class = "warning" }, content = _"Invalid PIN, please try again!" }
      slot.put("<br />")
    end

    ui.form{
      module = "registration", action = "register_pin", id = verification.id,
      content = function()
        ui.field.text{
          container_attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label" },
          attr = { id = "pin", class = "mdl-textfield__input", autofocus = "autofocus" },
          label_attr = { class = "mdl-textfield__label", ["for"] = "pin" },
          label = "PIN code",
          name = "pin"
        }

        slot.put("<br />")
    
        ui.tag{
          tag = "input",
          attr = {
            type = "submit",
            class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored",
            value = _"Proceed with registration"
          }
        }

        slot.put("<br /><br />")
        
        ui.heading{ content = _"No PIN code received?" }
        slot.put("<br />")
        ui.container { content = _"If you have not received a PIN code, our team will need to check your registration manually. We will be in touch within two working days. Please accept our apologies for the inconvenience." }
        
        slot.put("<br />")
        
        ui.tag{
          tag = "input",
          attr = {
            name = "manual_verification",
            type = "submit",
            class = "mdl-button mdl-js-button mdl-button--raised",
            value = _"Start manual verification"
          }
        }

      end
    }
    
    
  end }
end }
