function util.is_profile_field_locked(member, field_name)
  if member.authority == "ldap" then
    if config.ldap.member.locked_profile_fields and config.ldap.member.locked_profile_fields[field_name] 
        or field_name == "login" 
        or field_name == "password" 
    then
      return true
    end
  end

  if member.authority and string.sub(member.authority, 1, 7) == "oauth2_" then
    if field_name == "login" or field_name == "password" or field_name == "notify_email" then
      return true
    end
  end

  if config.locked_profile_fields[field_name] then
    return true
  end

  return false
end
