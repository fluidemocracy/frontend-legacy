function ui.field.wysihtml(args)
  
  local toolbar = {
    { command = "bold", title ="CTRL+B", icon = "format_bold" },
    { command = "italic", title ="CTRL+I", icon = "format_italic" },
    { command = "createLink", icon = "insert_link" },
    { command = "removeLink", icon = "insert_link", crossed = "\\" },
    { command = "formatBlock", command_value = "h1", icon = "title", head_level = "1" },
    { command = "formatBlock", command_value = "h2", icon = "title", head_level = "2" },
    { command = "formatBlock", command_value = "h3", icon = "title", head_level = "3" },
    { command = "formatBlock", command_blank = "true", icon = "format_clear" },
    { command = "insertBlockQuote", icon = "format_quote" },
    { command = "insertUnorderedList", icon = "format_list_bulleted" },
    { command = "insertOrderedList", icon = "format_list_numbered" },
    { command = "outdentList", icon = "format_indent_decrease" },
    { command = "indentList", icon = "format_indent_increase" },
--    { command = "alignLeftStyle", icon = "format_align_left" },
--    { command = "alignRightStyle", icon = "format_align_right" },
--    { command = "alignCenterStyle", icon = "format_align_center" },
    { command = "undo", icon = "undo" },
    { command = "redo", icon = "redo" }
  }

  slot.put([[
    <style>
      #wysihtml-html-button {
        padding: 2px;
        vertical-align: bottom;
      }
      #wysihtml-html-button.wysihtml-action-active {
        color: #fff;
        background: #000;
      }
    </style>
  ]])
  
  ui.container{ attr = { id = "toolbar", class = "toolbar", style = "display: none;" }, content = function()
    for i, t in ipairs(toolbar) do
      ui.tag{ tag = "a", attr = { ["data-wysihtml-command"] = t.command, ["data-wysihtml-command-value"] = t.command_value, ["data-wysihtml-command-blank-value"] = t.command_blank, title = t.shortcut }, content = function()
        ui.tag{ tag = "i", attr = { class = "material-icons" }, content = t.icon }
        if t.crossed then
          ui.tag{ attr = { class = "crossed" }, content = t.crossed }
        end
        if t.head_level then
          ui.tag{ attr = { class = "head_level" }, content = t.head_level }
        end
      end }
    end
    slot.put([[
      <div data-wysihtml-dialog="createLink" style="display: none;">
        <label>
          Link:
          <input data-wysihtml-dialog-field="href" value="http://">
        </label>
        <a data-wysihtml-dialog-action="save">OK</a>&nbsp;<a data-wysihtml-dialog-action="cancel">Cancel</a>
      </div>
    ]])
    slot.put([[      <a id="wysihtml-html-button" data-wysihtml-action="change_view">]] .. _"expert editor (HTML)" .. [[</a> ]])
  end }
  
  ui.field.text(args)

  ui.tag{ tag = "script", attr = { src = request.get_absolute_baseurl() .. "static/wysihtml/wysihtml.js" }, content = "" }
  ui.tag{ tag = "script", attr = { src = request.get_absolute_baseurl() .. "static/wysihtml/wysihtml.all-commands.js" }, content = "" }
  ui.tag{ tag = "script", attr = { src = request.get_absolute_baseurl() .. "static/wysihtml/wysihtml.toolbar.js" }, content = "" }
  ui.tag{ tag = "script", attr = { src = request.get_absolute_baseurl() .. "static/wysihtml/wysihtml_liquidfeedback_rules.js" }, content = "" }
  ui.script{ script = [[
    function initEditor() {
      var editor = new wysihtml.Editor("]] .. args.attr.id .. [[", {
        toolbar:       "toolbar",
        parserRules:   wysihtmlParserRules,
        useLineBreaks: true
      });
    }
    if(window.addEventListener){
      window.addEventListener('load', initEditor, false);
    } else {
      window.attachEvent('onload', initEditor);
    }
  ]] }

end
      
