local module = request.get_module()
local view = request.get_view()

local need_session = false
local cors_request = false

if module == "api" then
  need_session = false
elseif module == "oauth2" then
  if view == "authorization" then
    need_session = true
  elseif view == "session" then
    need_session = true
    cors_request = true
  else
    need_session = false
  end
else
  need_session = true
end

if need_session then

  local cookie = request.get_cookie{ name = config.cookie_name }

  if not cors_request then
    local cookie_samesite = request.get_cookie{ name = config.cookie_name_samesite }
    if cookie ~= cookie_samesite then
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
  end

  if cookie then
    app.session = Session:by_ident(cookie)
  end
end

if not app.session then
  app.session = Session:new()
  if need_session then
    app.session:set_cookie()
  end
end

locale.set{ lang = app.session and app.session.lang or config.default_lang or "en" }

if locale.get("lang") == "de" then
  locale.set{
    date_format = 'DD.MM.YYYY',
    time_format = 'HH:MM{:SS} Uhr',
    decimal_point = ','
  }
end

execute.inner()
