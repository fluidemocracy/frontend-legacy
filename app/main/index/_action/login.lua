local login = param.get("login")
local password = param.get("password")

local member, err, uid = Member:by_login_and_password(login, password)

if err == "ldap_credentials_valid_but_no_member" then
  app.session.authority = "ldap"
  app.session.authority_uid = uid
  app.session.authority_login = login
  app.session:save()
  request.redirect{
    module = "index", view = "register", params = {
      ldap_login = login
    }
  }
  return
end


if member then
  return util.login(member)

else
  slot.put_into("error_code", "invalid_credentials")
  trace.debug('User NOT authenticated')
  return false
end
