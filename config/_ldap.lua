config.ldap = {
  hosts = {
    {
      { uri = "ldap://192.168.1.1", tls = true, timeout = 5 },
      { uri = "ldap://192.168.1.2", tls = true, timeout = 5 },
    },
    { uri = "ldap://192.168.1.3", tls = true, timeout = 5 },
  },
  base = "dc=example,dc=org",
  bind_as = { dn = "cn=admin,dc=example,dc=org", password = "secure" },
  member = {
    registration = "auto",
    scope = "subtree",
    login_normalizer = function (login)
      return login:lower()
    end,
    login_filter_map = function (login)
      return "(uid=" .. ldap.escape_filter(login) .. ")"
    end,
    login_map = function (ldap_entry)
      return ldap_entry.uid[1]
    end,
    uid_filter_map = function (uid)
      return "(uidNumber=" .. ldap.escape_filter(uid) .. ")"
    end,
    uid_map = function (ldap_entry)
      return ldap_entry.uidNumber[1]
    end,
    fetch_attr = { "uid", "uidNumber", "givenName", "sn", "displayName", "memberof" },
    attr_map = function (ldap_entry, member)
      member.identification = ldap_entry.givenName[1] .. " " .. ldap_entry.sn[1]
      member.name = ldap_entry.displayName[1]
    end,
    privilege_map = function (ldap_entry, member)
      local privileges
      if ldap_entry.dn:match("ou=people,dc=example,dc=org") then
        privileges = {
          { unit_id = 1, voting_right = true, polling_right = true },
          { unit_id = 2, voting_right = true, polling_right = false },
          { unit_id = 3, voting_right = false, polling_right = true }
        }
      elseif ldap_entry.dn:match("ou=employees,dc=example,dc=org$") then
        privileges = {
          { unit_id = 1, voting_right = false, polling_right = true },
          { unit_id = 2, voting_right = false, polling_right = true },
          { unit_id = 3, voting_right = true, polling_right = false }
        }
      elseif ldap_entry.dn:match("ou=member,dc=example,dc=org$") then
        privileges = {
          { unit_id = 1, voting_right = true, polling_right = false }
        }
      end
      return privileges
    end,
    cache_passwords = true,
    locked_profile_fields = { name = true }
  }
}

