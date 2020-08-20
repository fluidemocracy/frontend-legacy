local cookie = request.get_cookie{ name = config.cookie_name }
local cookie_samesite = request.get_cookie{ name = config.cookie_name_samesite }

local oauth2_session_request = request.get_module() == "oauth2" and request.get_view() == "session"

if
  cookie and cookie ~= cookie_samesite and not oauth2_session_request
then
  slot.put_into("error", _"Cookie error. Try restarting your web browser and login again.")  
  ui.script{ script = [[
  function cookie_by_name(name) {
    var match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
    if (match) return match[2];
  }
  var cookie = (cookie_by_name("]] .. config.cookie_name .. [["));
  var cookie_samesite = (cookie_by_name("]] .. config.cookie_name_samesite ..[["));
  if (cookie != cookie_samesite) {
    document.cookie = "]] .. config.cookie_name .. [[= ; expires = Thu, 01 Jan 1970 00:00:00 GMT"
    document.cookie = "]] .. config.cookie_name_samesite .. [[= ; expires = Thu, 01 Jan 1970 00:00:00 GMT"
    window.location = "]] .. request.get_absolute_baseurl() .. [[";
  }
  ]]}
  return
end

if cookie then
  app.session = Session:by_ident(cookie)
end

if not app.session then
  app.session = Session:new()
  if not oauth2_session_request then
    app.session:set_cookie()
  end
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
