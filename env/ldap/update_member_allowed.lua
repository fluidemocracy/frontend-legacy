function ldap.update_member_allowed(member, ldap_entry)
  local allowed = config.ldap.member.allowed_map(ldap_entry)
  if allowed then
    member.locked = false
  else
    member.locked = true
    member.active = false
  end
end

