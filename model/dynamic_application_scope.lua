DynamicApplicationScope = mondelefant.new_class()
DynamicApplicationScope.table = 'dynamic_application_scope'
DynamicApplicationScope.primary_key = { "redirect_uri", "flow", "scope" }

function DynamicApplicationScope:by_redirect_uri_and_flow(redirect_uri, flow)
  local dynamic_application_scopes = self:new_selector()
    :add_where{ "redirect_uri = ?", redirect_uri }
    :add_where{ "flow = ?", flow }
    :add_where("expiry >= now()")
    :exec()
  return dynamic_application_scopes
end

function DynamicApplicationScope:check_scopes(domain, redirect_uri, requested_flow, requested_scopes)
  local function check_scopes(permitted_scopes)
    local missing_scope = false
    for scope in pairs(requested_scopes) do
      if not permitted_scopes[scope] then
        missing_scope = true
      end
    end
    return missing_scope
  end

  local registered = false
  local missing_scope = false

  local dynamic_application_scopes = DynamicApplicationScope:by_redirect_uri_and_flow(redirect_uri, requested_flow)

  if #dynamic_application_scopes > 0 then
    registered = true
    local permitted_scopes = {}
    for i, dynamic_application_scope in ipairs(dynamic_application_scopes) do
      permitted_scopes[dynamic_application_scope.scope] = true
    end
    missing_scope = check_scopes(permitted_scopes)
  end
  
  if not registered or missing_scope then
    local output, err, status = config.oauth2.host_func("_liquidfeedback_client." .. domain)
    if output == nil then
      error("Cannot execute host_func command")
    end
    if status == 0 then
      for line in string.gmatch(output, "[^\r\n]+") do
        local flow, result = string.match(line, '"dynamic client v1" "([^"]+)" (.+)$')
        if flow == requested_flow then
          registered = true
          local permitted_scopes = {}
          local wildcard = false
          for entry in string.gmatch(result, '"([^"]+)"') do
            if entry == "*" then
              wildcard = true
              break
            end
            permitted_scopes[entry] = true
          end
          if not wildcard then
            missing_scope = check_scopes(permitted_scopes)
          end
        end
      end
    end
  end
  
  if not registered then
    return "not_registered"
  elseif missing_scope then
    return "missing_scope"
  else
    return "ok"
  end
end
