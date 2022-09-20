function ldap.update_member_allowed(member, ldap_entry)
  local allowed = true
  if config.ldap.member.allowed_map then
    allowed = config.ldap.member.allowed_map(ldap_entry)
  end
  if allowed then
    member.locked = false
  else
    member.locked = true
    member.active = false
  end
end

