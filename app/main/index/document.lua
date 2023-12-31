if not config.document_dir then
  return execute.view { module = "index", view = "404" }
end

slot.put_into("title", _"Download documents")

slot.select("actions", function()
  ui.link{
    content = function()
        slot.put(_"Cancel")
    end,
    module = "index",
    view = "index"
  }
end)

local file_list = extos.listdir(config.document_dir)

local tmp = {}
for i, filename in ipairs(file_list) do
  if not filename:find("^%.") then
    tmp[#tmp+1] = filename
  end
end

local file_list = tmp

table.sort(file_list, function(a, b) return a > b end)

ui.list{
  records = file_list,
  columns = {
    {
      content = function(filename)
        slot.put(encode.html(filename))
      end
    },
    {
      content = function(filename)
        ui.link{
          content = _"Download",
          module = "index",
          view = "document_file",
          params = { filename = filename }
        }
        slot.put(" ")
        ui.link{
          content = _"Show",
          module = "index",
          view = "document_file",
          params = { filename = filename, inline = true }
        }
      end
    }
  }
}
