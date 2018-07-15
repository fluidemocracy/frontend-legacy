local function normalize_whitespace(str)
  str = string.gsub(str, "\194\160", " ")
  str = string.gsub(str, "&nbsp;", " ")
  return str
end

function util.wysihtml_preproc(str)
  str = string.gsub(str, "<a>(.-)</a>", "%1")
  str = string.gsub(str, "<[ou]l>[^<>]*", normalize_whitespace)
  str = string.gsub(str, "</li>[^<>]*", normalize_whitespace)
  return str
end
