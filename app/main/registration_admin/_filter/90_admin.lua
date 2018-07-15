if not app.session.member.admin then
  return execute.view { module = "index", view = "403" }
end

if config.admin_logger then
  config.admin_logger(request.get_param_strings())
end

execute.inner()
