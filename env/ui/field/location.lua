function ui.field.location(args)
  if config.map then
    ui.form_element(args, {fetch_value = true}, function(args)
      ui.tag{
        tag = "input",
        attr = { type = "hidden", name = args.name, value = args.value, id = "ui_field_location_value" }
      }
    end)
    ui.map({}, "ui_field_location_value")
  elseif config.firstlife then
    ui.form_element(args, {fetch_value = true}, function(args)
      ui.tag{
        tag = "input",
        attr = { type = "hidden", name = args.name, value = args.value, id = "ui_field_location_value" }
      }
      ui.tag{
        tag = "input",
        attr = { type = "hidden", name = args.name .. "_marker_link", value = args.value_marker_link, id = "ui_field_location_marker_link" }
      }
      ui.tag{ tag = "iframe", attr = { src = config.firstlife.inputmap_url .. "/src/index.html?domain=" .. request.get_absolute_baseurl() .. "&" .. config.firstlife.coordinates .. "&lightArea=false&contrast=false&mode=lite&onlypointer=false", id = "ui_field_location", class = "ui_field_location" }, content = "" }
      
      ui.script{ script = [[

        window.addEventListener("message", function (e) {
          if (e.origin !== "]] .. config.firstlife.inputmap_url .. [[") return;
          var data = e.data;
          if (data.src == "InputMap") {
            var feature = { "type": "Point", "coordinates": [data.lng, data.lat], "zoom_level": data.zoom_level };
            if (data.feature) {
              feature.marker_link = data.feature.marker_link;
            }
            var el = document.getElementById("ui_field_location_value");
            el.value = JSON.stringify(feature);
          }
        });
      ]] }
    end)
  end
end
