function util.scope_name(scope)
  local name
  for i, entry in ipairs(config.oauth2.available_scopes) do
    if entry.scope == scope then
      name = entry.name[locale.get("lang")] or entry.scope
    end
  end
  return name
end
