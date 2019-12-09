local cookie = request.get_cookie{ name = config.cookie_name or "liquid_feedback_session" }

if cookie then
  app.session = Session:by_ident(cookie)
end
if not app.session then
  app.session = Session:new()
  request.set_cookie{
    name = config.cookie_name or "liquid_feedback_session",
    value = app.session.ident
  }
end

locale.set{ lang = app.session.lang or config.default_lang or "en" }

if locale.get("lang") == "de" then
  locale.set{
    date_format = 'DD.MM.YYYY',
    time_format = 'HH:MM{:SS} Uhr',
    decimal_point = ','
  }
end

execute.inner()
