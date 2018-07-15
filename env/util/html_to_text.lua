function util.html_to_text(str)
  str = string.gsub(str, "[\0-\32]", " ")
  str = string.gsub(str, "<[Bb][Rr] */?>", "\n")
  str = string.gsub(str, "</?[Pp] *>", "\n\n")
  str = string.gsub(str, "</?[Bb] *>", "**")
  str = string.gsub(str, "</?[Ii] *>", "//")
  str = string.gsub(str, "</?[Ss][Uu][Bb] *>", "__")
  str = string.gsub(str, "</?[Ss][Uu][Pp] *>", "^^")
  str = string.gsub(str, '<[Aa] *[Hh][Rr][Ee][Ff] *= *"([^"]*)" *>', "[[%1 ")
  str = string.gsub(str, "<[Aa] *[Hh][Rr][Ee][Ff] *= *'([^']*)' *>", "[[%1 ")
  str = string.gsub(str, "<[Aa] *[Hh][Rr][Ee][Ff] *= *([^ <>\"']*) *>", "[[%1 ")
  str = string.gsub(str, "</[Aa] *>", "]]")
  str = string.gsub(str, "<[Hh]1 *>", "\n\n###### ")
  str = string.gsub(str, "<[Hh]2 *>", "\n\n##### ")
  str = string.gsub(str, "<[Hh]3 *>", "\n\n#### ")
  str = string.gsub(str, "<[Hh]4 *>", "\n\n### ")
  str = string.gsub(str, "<[Hh]5 *>", "\n\n## ")
  str = string.gsub(str, "<[Hh]6 *>", "\n\n# ")
  str = string.gsub(str, "</[Hh]1 *>", " ######\n\n")
  str = string.gsub(str, "</[Hh]2 *>", " #####\n\n")
  str = string.gsub(str, "</[Hh]3 *>", " ####\n\n")
  str = string.gsub(str, "</[Hh]4 *>", " ###\n\n")
  str = string.gsub(str, "</[Hh]5 *>", " ##\n\n")
  str = string.gsub(str, "</[Hh]6 *>", " #\n\n")
  local li_info = {}
  local pos = 1
  local counters = {}
  while true do
    local list_start, list_stop, list_tagname = string.find(str, "<(/?[OoUu]l) *>", pos)
    if list_tagname then
      list_tagname = string.lower(list_tagname)
    end
    local elem_start, elem_stop = string.find(str, "<[Ll][Ii] *>", pos)
    if list_start and not elem_start then
      pos = list_stop
    elseif elem_start and not list_start then
      pos = elem_stop
    elseif list_start and elem_start then
      if list_start < elem_start then
        pos = list_stop
      else
        pos = elem_stop
        list_tagname = nil
      end
    else
      break
    end
    if list_tagname == "ol" then
      counters[#counters+1] = 0
    elseif list_tagname == "ul" then
      counters[#counters+1] = false
    elseif list_tagname then
      counters[#counters] = nil
    else
      if counters[#counters] then
        counters[#counters] = counters[#counters] + 1
      end
      local string_parts = {}
      for idx, counter in ipairs(counters) do
        if counter then
          string_parts[idx] = tostring(counter) .. ". "
        else
          string_parts[idx] = "* "
        end
      end
      li_info[#li_info+1] = table.concat(string_parts)
    end
  end
  str = string.gsub(str, "</?[OoUu]l *>", "\n\n")
  local li_index = 0
  str = string.gsub(str, "<[Ll][Ii] *>", function()
    li_index = li_index + 1
    return li_info[li_index]
  end)
  str = string.gsub(str, "</[Ll][Ii] *>", "\n")
  str = string.gsub(str, "<[^<>]*>", "")
  str = string.gsub(str, "<", "&lt;")
  str = string.gsub(str, ">", "&gt;")
  str = string.gsub(str, "  +", " ")
  str = string.gsub(str, "%f[^\0\n] ", "")
  str = string.gsub(str, " %f[\0\n]", "")
  str = string.gsub(str, "\n\n\n+", "\n\n")
  str = string.gsub(str, "^\n+", "")
  str = string.gsub(str, "\n*$", "\n")
  return str
end
