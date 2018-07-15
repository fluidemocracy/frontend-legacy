Token = mondelefant.new_class()
Token.table = 'token'

Token:add_reference{
  mode          = '1m',
  to            = "TokenScope",
  this_key      = 'id',
  that_key      = 'token_id',
  ref           = 'token_scopes',
  back_ref      = 'token',
  default_order = 'token_scope.index'
}

Token:add_reference{
  mode          = 'm1',
  to            = "Member",
  this_key      = 'member_id',
  that_key      = 'id',
  ref           = 'member',
}

Token:add_reference{
  mode          = 'm1',
  to            = "Session",
  this_key      = 'session_id',
  that_key      = 'id',
  ref           = 'session',
}

Token:add_reference{
  mode          = 'm1',
  to            = "SystemApplication",
  this_key      = 'system_application_id',
  that_key      = 'id',
  ref           = 'system_application',
}

function Token:new()
  local token = self.prototype.new(self)
  token.token = multirand.string(16, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
  return token
end

function Token:create_authorization(member_id, system_application_id, domain, session_id, redirect_uri, redirect_uri_explicit, scopes, state)

  local detached = false
  for i = 0, #scopes do
    if scopes[i] then
      for s in string.gmatch(scopes[i], "[^ ]+") do
        if s == "detached" then
          detached = true
        end
      end
    end
  end
  
  local requested_scopes = {}

  for i = 0, #scopes do
    if scopes[i] then
      for scope in string.gmatch(scopes[i], "[^ ]+") do
        requested_scopes[scope] = true
      end
    end
  end

  local requested_scopes_list = {}

  for k, v in pairs(requested_scopes) do
    requested_scopes_list[#requested_scopes_list+1] = k
  end

  local requested_scopes_string = table.concat(requested_scopes_list, " ")

  local expiry = db:query({"SELECT now() + (? || 'sec')::interval AS expiry", config.oauth2.authorization_code_lifetime }, "object").expiry

  local token = Token:new()
  token.token_type = "authorization"
  token.member_id = member_id
  token.system_application_id = system_application_id
  token.domain = domain
  if not detached then
    token.session_id = session_id
  end
  token.redirect_uri = redirect_uri
  token.redirect_uri_explicit = redirect_uri_explicit
  token.expiry = expiry
  token.scope = requested_scopes_string

  token:save()
  
  for i = 0, #scopes do
    if scopes[i] then
      local token_scope = TokenScope:new()
      token_scope.token_id = token.id
      token_scope.index = i
      token_scope.scope = scopes[i]
      token_scope:save()
    end
  end
  

  return token, target_uri
end

function Token:by_token_type_and_token(token_type, token)
  local selector = Token:new_selector()
  selector:add_where{ "token_type = ?", token_type }
  selector:add_where{ "token = ?", token }
  selector:add_where{ "expiry > now()" }
  selector:optional_object_mode()
  if token_type == "authorization_code" then
    selector:for_update()
  end
  if token_type == "access_token" then
    selector:add_field("FLOOR(EXTRACT(EPOCH FROM expiry - now()))", "expiry_in")
  end
  return selector:exec()
end

function Token:refresh_token_by_token_selector(token)
  local selector = Token:new_selector()
  selector:add_where{ "token_type = ?", "refresh" }
  selector:add_where{ "member_id = ?", token.member_id }
  if token.system_application_id then
    selector:add_where{ "system_application_id = ?", token.system_application_id }
  else
    selector:add_where{ "domain = ?", token.domain }
  end
  return selector
end

function Token:fresh_refresh_token_by_token(token)
  local selector = Token:refresh_token_by_token_selector(token)
  selector:add_where{ "created + ('?' || ' sec')::interval > now()", config.oauth2.refresh_pause }
  selector:add_where{ "regexp_split_to_array(scope, E'\\\\s+') <@ regexp_split_to_array(?, E'\\\\s+')", token.scope }
  selector:add_where{ "regexp_split_to_array(scope, E'\\\\s+') @> regexp_split_to_array(?, E'\\\\s+')", token.scope }
  return selector:exec()
end

function Token:old_refresh_token_by_token(token, scopes)
  local selector = Token:refresh_token_by_token_selector(token)
  selector:add_where{ "id < ?", token.id }
  selector:add_where{ "created + ('?' || ' sec')::interval <= now()", config.oauth2.refresh_grace_period }
  selector:add_where{ "regexp_split_to_array(scope, E'\\\\s+') && regexp_split_to_array(?, E'\\\\s+')", scopes }
  return selector:exec()
end
