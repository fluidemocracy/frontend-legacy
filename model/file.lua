File = mondelefant.new_class()
File.table = "file"
File.primary_key = "id"

File.binary_columns = { 
  data = true,
  preview_data = true
}
