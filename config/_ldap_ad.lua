local function str2hex(s)
  local t = {string.byte(s, 1, #s)}
  local f = string.format
  for i = 1, #t do t[i] = f("\\%02x", t[i]) end
  return table.concat(t)
end

config.ldap = {
  hosts = { 
    { uri = "ldap://192.168.1.1", tls = true, timeout = 5 },
    { uri = "ldap://192.168.1.2", tls = true, timeout = 5 }
  },
  base = "CN=Users,DC=example,DC=org",
  bind_as = { dn = "CN=LiquidFeedback Service,CN=Users,DC=example,DC=org", password = "secure" },
  member = {
    registration = "auto",
    scope = "subtree",
    login_normalizer = function (login)
      return login:lower()
    end,
    login_filter_map = function (login)
      return "(sAMAccountName=" .. ldap.escape_filter(login) .. ")"
    end,
    login_map = function (ldap_entry)
      return ldap_entry.sAMAccountName[1]
    end,
    uid_filter_map = function (uid)
      return "(objectGUID=" .. uid .. ")"
    end,
    uid_map = function (ldap_entry)
      return str2hex(ldap_entry.objectGUID[1])
    end,
    allowed_map = function (ldap_entry)
      local allowed = false
      if ldap_entry.memberOf then
        for i, group in ipairs(ldap_entry.memberOf) do
          if group == "CN=LiquidFeedback User,CN=Users,DC=example,DC=org" then
            allowed = true
          end
        end
      end
      return allowed
    end,
    fetch_attr = { "sAMAccountName", "objectGUID", "givenName", "name", "displayName", "memberOf" },
    attr_map = function (ldap_entry, member)
      member.identification = ldap_entry.givenName[1] .. " " .. ldap_entry.name[1]
      member.name = ldap_entry.displayName[1]
    end,
    privilege_map = function (ldap_entry, member)
      local privileges = {}
      if ldap_entry.memberOf then
        for i, group in ipairs(ldap_entry.memberOf) do
          if group == "CN=LiquidFeedback User,CN=Users,DC=example,DC=org" then
            table.insert(privileges,
              { unit_id = 1, voting_right = true, polling_right = true }
            )
          end
        end
      end
      return privileges
    end,
    cache_passwords = true,
    locked_profile_fields = { name = true }
  }
}

