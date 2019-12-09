Session = mondelefant.new_class()
Session.table = 'session'
Session.primary_key = { 'ident' } 

Session:add_reference{
  mode          = 'm1',
  to            = "Member",
  this_key      = 'member_id',
  that_key      = 'id',
  ref           = 'member',
}

Session:add_reference{
  mode          = 'm1',
  to            = "Member",
  this_key      = 'real_member_id',
  that_key      = 'id',
  ref           = 'real_member',
}

local secret_length = 24
local secret_alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
local secret_purposes = { "oauth", "_other" }
for idx, purpose in ipairs(secret_purposes) do
  secret_purposes[purpose] = idx
end

local function random_string(length_multiplier)
  return multirand.string(
    secret_length * (length_multiplier or 1),
    secret_alphabet
  )
end

function Session:new()
  local session = self.prototype.new(self)  -- super call
  session.ident             = random_string()
  session.additional_secret = random_string(#secret_purposes)
  session:save()
  return session
end

function Session.object:additional_secret_for(purpose)
  local use_hash = false
  local idx = secret_purposes[purpose]
  if not idx then
    idx = assert(secret_purposes._other, "No other secrets supported")
    use_hash = true
  end
  local from_pos = secret_length * (idx-1) + 1
  local to_pos = from_pos + secret_length - 1
  local secret = string.sub(self.additional_secret, from_pos, to_pos)
  if #secret ~=  secret_length then
    self:destroy()
    error("Session state invalid")
  end
  if use_hash then
    local moonhash = require "moonhash"  -- TODO: auto loader for libraries in WebMCP?
    secret = moonhash.shake256(secret .. "\0" .. purpose, secret_length, secret_alphabet)
  end
  return secret
end

function Session:by_ident(ident)
  local selector = self:new_selector()
  selector:add_where{ 'ident = ?', ident }
  selector:add_field{ 'authority_uid' }
  selector:optional_object_mode()
  return selector:exec()
end

function Session.object:has_access(level)
  if level == "member" then
    if app.session.member_id then
      return true
    else
      return false
    end
  
  elseif level == "everything" then
    if self:has_access("member") or config.public_access == "everything" then
      return true
    else
      return false
    end

  elseif level == "all_pseudonymous" then
    if self:has_access("everything") or config.public_access == "all_pseudonymous" then
      return true
    else
      return false
    end

  elseif level == "authors_pseudonymous" then
    if self:has_access("all_pseudonymous") or config.public_access == "authors_pseudonymous" then
      return true
    else
      return false
    end

  elseif level == "anonymous" then
    if self:has_access("authors_pseudonymous") or config.public_access == "anonymous" then
      return true
    else
      return false
    end
    
  end
  
  error("invalid access level")
end
