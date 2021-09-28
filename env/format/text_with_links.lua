function format.text_with_links(value)
  value = encode.html(value)
  value = encode.html_newlines(value)
  value = string.gsub(value, "http[^%s:]*://[^%s]+", function(match)
    return "<a href=\"" .. match .. "\">" .. match .. "</a>"
  end)
  return value
end
