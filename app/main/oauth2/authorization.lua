local function show_error(text)
  ui.title("Authorization")
  ui.section(function()
    ui.sectionHead(function()
      ui.heading{ content = _"Error during authorization" }
    end)
    ui.sectionRow(function()
      ui.container{ content = text }
    end )
  end )
end

local client_id = param.get("client_id")
local redirect_uri = param.get("redirect_uri")
local redirect_uri_explicit = redirect_uri and true or false
local response_type = param.get("response_type")
local state = param.get("state")

local no_scope_requested = true

local scopes = {
  [0] = param.get("scope")
}

for i = 1, math.huge do
  scopes[i] = param.get("scope" .. i)
  if not scopes[i] then
    break
  end
end

if #scopes == 0 and not scopes[0] then
  scopes[0] = "identification"
end

local requested_scopes = {}

for i = 0, #scopes do
  if scopes[i] then
    for scope in string.gmatch(scopes[i], "[^ ]+") do
      requested_scopes[scope] = true
    end
  end
end

local system_application
local member_application
local client_name
local scopes_to_accept = table.new(requested_scopes)
local accepted_scopes = {}

local domain

if client_id then
  domain = string.match(client_id, "^dynamic:([a-z0-9.-]+)$")
end

local dynamic_application_check
if domain then
  if #domain > 255 then
    return show_error(_"Domain too long")
  end
  if string.find(domain, "^%.") or string.find(domain, "%.$") or string.find(domain, "%.%.") then
    return show_error(_"Invalid domain format")
  end
  if redirect_uri then
    local redirect_uri_domain, magic = string.match(redirect_uri, "^[Hh][Tt][Tt][Pp][Ss]://([A-Za-z0-9_.-]+)/(.*)$")
    if not redirect_uri_domain or string.lower(redirect_uri_domain) ~= domain or magic ~= config.oauth2.endpoint_magic then
      return show_error(_"Redirect URI forbidden")
    end
  else
    redirect_uri = "https://" .. domain .. "/" .. config.oauth2.endpoint_magic
  end
  dynamic_application_check = DynamicApplicationScope:check_scopes(domain, redirect_uri, response_type, requested_scopes)
  if dynamic_application_check == "not_registered" then
    return show_error(_"Redirect URI or response type not registered")
  end
  client_name = domain
  member_application = MemberApplication:by_member_id_and_domain(app.session.member_id, domain)
  if member_application then
    for scope in string.gmatch(member_application.scope, "[^ ]+") do
      accepted_scopes[scope] = true
      scopes_to_accept[scope] = nil
    end
  end
else
  system_application = SystemApplication:by_client_id(client_id)
  if system_application then
    if redirect_uri_explicit then
      if 
        redirect_uri ~= system_application.default_redirect_uri 
        and not SystemApplicationRedirectUri:by_pk(system_application.id, redirect_uri) 
      then
        return show_error(_"Redirect URI invalid")
      end
    else
      redirect_uri = system_application.default_redirect_uri
    end
    if system_application.flow ~= response_type then
      return show_error(_"Response type not allowed for given client")
    end
    client_name = system_application.name
    member_application = MemberApplication:by_member_id_and_system_application_id(app.session.member_id, system_application.id)
  end
end

if not client_name then
  return show_error(_"Client ID invalid")
end

local function error_redirect(error_code, description)
  local params = {
    state = state,
    error = error_code,
    error_description = description
  }
  if response_type == "token" then
    local anchor_params_list = {}
    for k, v in pairs(params) do
      anchor_params_list[#anchor_params_list+1] = k .. "=" .. encode.url_part(v)
    end
    local anchor = table.concat(anchor_params_list, "&")
    request.redirect{
      external = redirect_uri .. "#" .. anchor
    }
  else
    request.redirect{ 
      external = redirect_uri,
      params = params
    }
  end
end

if response_type ~= "code" and response_type ~= "token" then
  return error_redirect("unsupported_response_type", "Invalid response type")
end

for i = 0, #scopes do
  if scopes[i] == "" then
    return error_redirect("invalid_scope", "Empty scope requested")
  end
end

for scope in pairs(requested_scopes) do
  local scope_valid = false
  for i, entry in ipairs(config.oauth2.available_scopes) do
    if scope == entry.scope or scope == entry.scope .. "_detached" then
      scope_valid = true
      break
    end
  end
  if not scope_valid then
    return error_redirect("invalid_scope", "Requested scope not available")
  end
end

if system_application then
  if system_application.permitted_scope then
    local permitted_scopes = {}
    for scope in string.gmatch(system_application.permitted_scope, "[^ ]+") do
      permitted_scopes[scope] = true
    end
    for scope in pairs(requested_scopes) do
      if not permitted_scopes[scope] then
        return error_redirect("invalid_scope", "Scope not permitted")
      end
    end
  end
  if system_application.forbidden_scope then
    for scope in string.gmatch(system_application.forbidden_scope, "[^ ]+") do
      if requested_scopes[scope] then
        return error_redirect("invalid_scope", "Scope forbidden")
      end
    end
  end
  if system_application.automatic_scope then
    for scope in string.gmatch(system_application.automatic_scope, "[^ ]+") do
      scopes_to_accept[scope] = nil
      accepted_scopes[scope] = true
    end
  end
  if member_application then
    for scope in string.gmatch(member_application.scope, "[^ ]+") do
      scopes_to_accept[scope] = nil
      accepted_scopes[scope] = true
    end
  end
else
  if dynamic_application_check == "missing_scope" then
    return error_redirect("invalid_scope", "Scope not permitted")
  end
end

if next(scopes_to_accept) then
  ui.title("Application authorization")
  ui.section(function()
    ui.sectionHead(function()
      ui.heading{ content = client_name }
      ui.heading{ content = "wants to access your account" }
    end)
    if not system_application and not member_application then
      ui.sectionRow(function()
        ui.container{ content = _"Warning: Untrusted third party application." }
      end)
    end
    ui.sectionRow(function()
      ui.heading{ level = 3, content = _"Requested privileges:" }
      ui.tag{ tag = "ul", attr = { class = "ul" }, content = function()
        for i, entry in ipairs(config.oauth2.available_scopes) do
          local name = entry.name[locale.get("lang")] or entry.scope
          if accepted_scopes[entry.scope] or requested_scopes[entry.scope] or accepted_scopes[entry.scope .. "_detached"] or requested_scopes[entry.scope .. "_detached"] then
            ui.tag{ tag = "li", content = function()
              ui.tag{ content = name }
              if accepted_scopes[entry.scope .. "_detached"] or requested_scopes[entry.scope .. "_detached"] then
                slot.put(" ")
                ui.tag{ content = _"(detached)" }
              end
              if scopes_to_accept[entry.scope] or scopes_to_accept[entry.scope .. "_detached"] then
                slot.put(" ")
                ui.tag{ content = _"(new)" }
              end
              -- TODO display changes
            end }
          end
        end
      end }
    end )
    local params = {
      system_application_id = system_application and system_application.id or nil,
      domain = domain,
      redirect_uri = redirect_uri,
      redirect_uri_explicit = redirect_uri_explicit,
      state = state,
      response_type = response_type
    }
    for i = 0, #scopes do
      params["scope" .. i] = scopes[i]
    end
    ui.form{
      module = "oauth2", action = "accept_scope", params = params,
      routing = { default = { mode = "redirect", module = "oauth2", view = "authorization", params = request.get_param_strings() } },
      content = function()
        ui.sectionRow(function()
          ui.submit{ text = _"Grant authorization", attr = { class = "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--colored " } }
          slot.put(" &nbsp; ")
          ui.link{ content = _"Decline authorization", attr = { class = "mdl-button mdl-js-button" }, external = redirect_uri, params = { error = "access_denied", error_description = "User declined to authorize client" } }
        end )
      end
    }
  end )
else
  
  execute.chunk{ module = "oauth2", chunk = "_authorization", params = {
    member_id = app.session.member_id, 
    system_application_id = system_application and system_application.id or nil, 
    domain = domain, 
    session_id = app.session.id, 
    redirect_uri = redirect_uri, 
    redirect_uri_explicit = redirect_uri_explicit, 
    scopes = scopes, 
    state = state,
    response_type = response_type
  } }


end

