local draft = param.get("draft", "table")
local source = param.get("source", atom.boolean)

ui.form{
  attr = { class = "vertical" },
  record = draft,
  readonly = true,
  content = function()

    ui.container{
      attr = { class = "draft_content wiki" },
      content = function()
        if source then
          ui.tag{
            tag = "pre",
            content = draft.content
          }
        else
          slot.put(draft:get_content("html"))
        end
      end
    }
  end
}
