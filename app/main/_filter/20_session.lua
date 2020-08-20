local cookie = request.get_cookie{ name = config.cookie_name }
local cookie_samesite = request.get_cookie{ name = config.cookie_name_samesite }

if
  cookie and cookie ~= cookie_samesite 
  and not (request.get_module() == "oauth" and request.get_view() == "session")
then
  slot.put_into("error", _"Cookie error. Try restarting your web browser and login again.")  
  return
end

if cookie then
  app.session = Session:by_ident(cookie)
end
if not app.session then
  app.session = Session:new()
  app.session:set_cookie()
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
