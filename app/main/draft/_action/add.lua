local draft_text = param.get("content")

if not draft_text then
  return false
end

local draft_text = util.wysihtml_preproc(draft_text)

local valid_html, error_message = util.html_is_safe(draft_text)
if not valid_html then
  slot.put_into("error", _("Draft contains invalid formatting or character sequence: #{error_message}", { error_message = error_message }) )
  return false
end

if config.initiative_abstract then
  local abstract = param.get("abstract")
  if not abstract then
    return false
  end
  abstract = encode.html(abstract)
  draft_text = abstract .. "<!--END_OF_ABSTRACT-->" .. draft_text
end

return Draft:update_content(
  app.session.member.id, 
  param.get("initiative_id", atom.integer),
  param.get("formatting_engine"),
  draft_text,
  nil,
  param.get("preview") or param.get("edit")
)
