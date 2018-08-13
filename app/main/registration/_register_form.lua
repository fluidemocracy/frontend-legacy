for i, field in ipairs(config.self_registration.fields) do
  local class = ""
  local field_error = slot.get_content("self_registration__invalid_" .. field.name)
  if field_error == "" then
    field_error = nil
  end
  if field_error then
    class = " is-invalid"
  end
  if not field.internal then
    if field.name == "date_of_birth" then
      local label = field.label
      if field.optional then
        label = label .. config.self_registration.optional_field_indicator
      end
      ui.tag{ tag = "label", attr = { style = "vertical-align: bottom; border-bottom: 1px solid rgba(0,0,0, 0.12); color: #777; font-size: 16px;" }, content = field.label .. ":" }
      slot.put(" &nbsp; ")
      local days = { { id = 0, name = _"day" } }
      for i = 1, 31 do
        table.insert(days, { id = i, name = i })
      end
      local months = {
        { id = 0, name = _"month" },
        { id = 1, name = "gennaio" },
        { id = 2, name = "febbraio" },
        { id = 3, name = "marzo" },
        { id = 4, name = "aprile" },
        { id = 5, name = "maggio" },
        { id = 6, name = "giugno" },
        { id = 7, name = "luglio" },
        { id = 8, name = "agosto" },
        { id = 9, name = "settembre" },
        { id = 10, name = "ottobre" },
        { id = 11, name = "novembre" },
        { id = 12, name = "dicembre" },
      }
      if config.self_registration.lang == "en" then
        months = {
          { id = 0, name = _"month" },
          { id = 1, name = "January" },
          { id = 2, name = "February" },
          { id = 3, name = "March" },
          { id = 4, name = "April" },
          { id = 5, name = "May" },
          { id = 6, name = "June" },
          { id = 7, name = "July" },
          { id = 8, name = "August" },
          { id = 9, name = "September" },
          { id = 10, name = "October" },
          { id = 11, name = "November" },
          { id = 12, name = "December" },
        }
      end
      local years = { { id = 0, name = _"year" } }
      for i = 2002, 1900, -1 do
        table.insert(years, { id = i, name = i })
      end
      ui.field.select{
        container_attr = { style = "display: inline-block; " },
        attr = { class = class },
        foreign_records = days,
        foreign_id = "id",
        foreign_name = "name",
        name = "verification_data_" .. field.name .. "_day",
        value = tonumber(request.get_param{ name = "verification_data_" .. field.name .. "_day" })
      }
      slot.put(" &nbsp; ")
      ui.field.select{
        container_attr = { style = "display: inline-block; " },
        attr = { class = class },
        foreign_records = months,
        foreign_id = "id",
        foreign_name = "name",
        name = "verification_data_" .. field.name .. "_month",
        value = tonumber(request.get_param{ name = "verification_data_" .. field.name .. "_month" })
      }
      slot.put(" &nbsp; ")
      ui.field.select{
        container_attr = { style = "display: inline-block; " },
        attr = { class = class },
        foreign_records = years,
        foreign_id = "id",
        foreign_name = "name",
        name = "verification_data_" .. field.name .. "_year",
        value = tonumber(request.get_param{ name = "verification_data_" .. field.name .. "_year" })
      }
      slot.put("<br />")
    
    elseif field.type == "dropdown" then
      local options = { { id = "", name = "" } }
      for i_options, option in ipairs(field.options) do
        table.insert(options, option)
      end
      ui.tag{ tag = "label", attr = { style = "vertical-align: bottom; border-bottom: 1px solid rgba(0,0,0, 0.12); color: #777; font-size: 16px;" }, content = field.label .. ":" }
      slot.put(" &nbsp; ")
      ui.field.select{
        container_attr = { style = "display: inline-block; " },
        attr = { class = class },
        foreign_records = options,
        foreign_id = "id",
        foreign_name = "name",
        name = "verification_data_" .. field.name,
        value = tonumber(request.get_param{ name = "verification_data_" .. field.name })
      }
      slot.put("<br />")

    elseif field.type == "image" then
      slot.put("<br />")
      ui.tag{ tag = "label", attr = { style = "vertical-align: bottom; border-bottom: 1px solid rgba(0,0,0, 0.12); color: #777; font-size: 16px;" }, content = field.label .. ":" }
      slot.put("<br />")
      ui.script{ script = [[
        function getFile(){
          document.getElementById("fileInput").click();
        }
        function fileChoosen(obj){
          var file = obj.value;
          var fileName = file.split("\\");
          var checked = false;
          var label = "]] .. field.upload_label .. [[";
          if (fileName[fileName.length-1].length > 0) {
            label = fileName[fileName.length-1];
          }
          document.getElementById("fileBtn").innerHTML = label;
          event.preventDefault();
        }
      ]] }
      ui.tag{ tag = "input", attr = { id = "fileInput", style = "display: none;", type = "file", name = "verification_data_" .. field.name, onchange = "fileChoosen(this);" } }
      ui.tag{
        attr = { id = "fileBtn", class = "mdl-button mdl-js-button mdl-button--underlined", onclick = "getFile();" },
        content = field.upload_label
      }
      if field.optional_checkbox then
        slot.put(" &nbsp; ")
        ui.tag{ tag = "label", attr = {
            class = "mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect",
            style = "display: inline;",
            ["for"] = "verification_data_" .. field.name .. "_optout"
          },
          content = function()
            ui.tag{
              tag = "input",
              attr = {
                type = "checkbox",
                class = "mdl-checkbox__input",
                id = "verification_data_" .. field.name .. "_optout",
                name = "verification_data_" .. field.name .. "_optout",
                value = "1",
                style = "float: left;",
                checked = request.get_param{ name = "verification_data_" .. field.name .. "_optout" } and "checked" or nil,
              }
            }
            ui.tag{
              attr = { class = "mdl-checkbox__label" },
              content = field.optional_checkbox
            }
          end
        }
      end
      
    elseif field.name == "unit" then
      local units_selector = Unit:new_selector()
        :add_where{ "active" }
      if field.where then
        units_selector:add_where(field.where)
      end
      local units = {}
      if field.optional then
        table.insert(units, {
          id = "",
          name = _"None"
        })
      end
      for i_unit, unit in ipairs(units_selector:exec()) do
        table.insert(units, unit)
      end
      ui.tag{ tag = "label", attr = { style = "vertical-align: bottom; border-bottom: 1px solid rgba(0,0,0, 0.12); color: #777; font-size: 16px;" }, content = field.label .. ":" }
      slot.put(" &nbsp; ")
      ui.field.select{
        container_attr = { style = "display: inline-block; " },
        foreign_records = units,
        foreign_id = "id",
        foreign_name = "name",
        name = "verification_data_" .. field.name,
        value = tonumber(request.get_param{ name = "verification_data_" .. field.name })
      }
      slot.put("<br />")
    else
      if field.name == "mobile_phone" then
        if config.self_registration.lang ~= "en" then
          ui.tag{ content = "+39" }
          slot.put(" ")
        end
      end
      ui.field.text{
        container_attr = { class = "mdl-textfield mdl-js-textfield mdl-textfield--floating-label" .. class },
        attr = { id = "lf-register__data_" .. field.name, class = "mdl-textfield__input" },
        label_attr = { class = "mdl-textfield__label", ["for"] = "lf-register__data" .. field.name },
        label = field.label,
        name = "verification_data_" .. field.name,
        value = request.get_param{ name = "verification_data_" .. field.name }
      }
    end
    slot.put("<br />")
  end
end
