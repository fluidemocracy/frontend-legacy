if not app.session.member.admin then
  error('access denied')
end

if config.admin_logger then
  config.admin_logger(cgi.params)
end

execute.inner()
