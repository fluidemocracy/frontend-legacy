config.app_version = "4.0.0"

-- TODO abstraction
-- get record by id
function mondelefant.class_prototype:by_id(id)
  local selector = self:new_selector()
  selector:add_where{ 'id = ?', id }
  selector:optional_object_mode()
  return selector:exec()
end

if not config.password_hash_algorithm then
  config.password_hash_algorithm = "crypt_sha512"
end

if not config.password_hash_min_rounds then
 config.password_hash_min_rounds = 10000
end

if not config.password_hash_max_rounds then
  config.password_hash_max_rounds = 20000
end

if config.use_terms_checkboxes == nil then
  config.use_terms_checkboxes = {}
end

if config.enabled_languages == nil then
  config.enabled_languages = { 'en', 'de', 'ka' } --, 'eo', 'el', 'hu', 'it', 'nl', 'zh-Hans', 'zh-TW' }
end

if config.default_lang == nil then
  config.default_lang = "en"
end

if config.mail_subject_prefix == nil then
  config.mail_subject_prefix = "[LiquidFeedback] "
end

if config.notification_digest_template == nil then
  config.notification_digest_template = "Hello #{name},\n\nthis is your personal digest.\n\n#{digest}\n"
end

if config.member_image_content_type == nil then
  config.member_image_content_type = "image/jpeg"
end

if config.member_image_convert_func == nil then
  config.member_image_convert_func = {
    avatar = function(data) return extos.pfilter(data, "convert", "jpeg:-", "-thumbnail",   "48x48", "jpeg:-") end,
    photo =  function(data) return extos.pfilter(data, "convert", "jpeg:-", "-thumbnail", "240x240", "jpeg:-") end
  }
end

if config.locked_profile_fields == nil then
  config.locked_profile_fields = {}
end

if config.check_delegations_default == nil then
  config.check_delegations_default = "confirm"
end

if config.cookie_name == nil then
  config.cookie_name = "liquid_feedback_session"
end

if config.cookie_name_samesite == nil then
  config.cookie_name_samesite = config.cookie_name .. "_samesite"
end

if config.ldap == nil then
  config.ldap = {}
end

if config.oauth2 then
  local scopes = {
    { scope = "authentication", name = { de = "Identität feststellen (nur Screen-Name)", en = "Determine identity (screen name only)" } },
    { scope = "identification", name = { de = "Identität feststellen", en = "Determine identity" } },
    { scope = "notify_email", name = { de = "E-Mail-Adresse für Benachrichtigungen verwenden", en = "Use email address for notifications" } },
    { scope = "read_contents", name = { de = "Inhalte lesen", en = "Read content" } },
    { scope = "read_authors", name = { de = "Autorennamen lesen", en = "Read author names" } },
    { scope = "read_ratings", name = { de = "Bewertungen lesen", en = "Read ratings" } },
    { scope = "read_identities", name = { de = "Identitäten lesen", en = "Read identities" } },
    { scope = "read_profiles", name = { de = "Profile lesen", en = "Read profiles" } },
    { scope = "post", name = { de = "Neue Inhalte veröffentlichen", en = "Post new content" } },
    { scope = "rate", name = { de = "Bewertungen vornehmen", en = "Do ratings" } },
    { scope = "vote", name = { de = "Abstimmen", en = "Vote" } },
    { scope = "delegate", name = { de = "Delegieren", en = "Delegate" } },
    { scope = "profile", name = { de = "Eigenes Profil lesen", en = "Read your profile" } },
    { scope = "settings", name = { de = "Einstellungen einsehen", en = "Read your settings" } },
    { scope = "update_name", name = { de = "Screen-Namen ändern", en = "Update screen name" } },
    { scope = "update_notify_email", name = { de = "E-Mail-Adresse für Benachrichtigungen ändern", en = "Update notify email address" } },
    { scope = "update_profile", name = { de = "Profil bearbeiten", en = "Update your profile" } },
    { scope = "update_settings", name = { de = "Benutzereinstellungen ändern", en = "Update your settings" } },
    { scope = "login", name = { de = "Login", en = "Login" } }
  }
  local s = config.oauth2.available_scopes or {}
  for i, scope in ipairs(scopes) do
    s[#s+1] = scope
  end
  config.oauth2.available_scopes = s
  if not config.oauth2.endpoint_magic then
    config.oauth2.endpoint_magic = "liquidfeedback_client/redirection_endpoint"
  end
  if not config.oauth2.manifest_magic then
    config.oauth2.manifest_magic = "liquidfeedback_client/manifest"
  end
  if not config.oauth2.host_func then
    config.oauth2.host_func = function(domain) return extos.pfilter(nil, "host", "-t", "TXT", domain) end
  end
  if not config.oauth2.authorization_code_lifetime then
    config.oauth2.authorization_code_lifetime = 5 * 60
  end
  if not config.oauth2.refresh_token_lifetime then
    config.oauth2.refresh_token_lifetime = 60 * 60 * 24 * 30 * 3
  end
  if not config.oauth2.refresh_pause then
    config.oauth2.refresh_pause = 60
  end
  if not config.oauth2.refresh_grace_period then
    config.oauth2.refresh_grace_period = 60
  end
  if not config.oauth2.access_token_lifetime then
    config.oauth2.access_token_lifetime = 60 * 60
  end
  if not config.oauth2.dynamic_registration_lifetime then
    config.oauth2.dynamic_registration_lifetime = 60 * 60 * 24
  end
  if config.oauth2.refresh_pause < config.oauth2.refresh_grace_period then
    print("ERROR: config.auth2.refresh_pause is smaller than config.oauth2.refresh_grace_period")
    os.exit()
  end
end

if not config.database then
  config.database = { engine='postgresql', dbname='liquid_feedback' }
end

if not config.formatting_engines then
  config.enforce_formatting_engine = "html"
  config.formatting_engines = {
    { id = "html",
      name = "html",
      executable = "cat"
    }
  }
end

if not config.style then
  config.style = {
    color_md = {
      primary = "green",
      primary_contrast = "dark",
      accent = "blue",
      accent_contrast = "dark"
    }
  }
end

if not config.member_profile_fields then
  config.member_profile_fields = {}
end


if config.fork == nil then
  config.fork = {}
end

if config.fork.pre == nil then
  config.fork.pre = 2
end

if config.fork.min == nil then
  config.fork.min = 4
end

if config.fork.max == nil then
  config.fork.max = 128
end

if config.fork.delay == nil then
  config.fork.delay = 0.125
end

if config.fork.error_delay == nil then
  config.fork.error_delay = 2
end

if config.fork.exit_delay == nil then
  config.fork.exit_delay = 2
end

if config.fork.idle_timeout == nil then
  config.fork.idle_timeout = 900
end

if config.port == nil then
  config.port = 8080
end

if config.localhost == nil then
  config.localhost = true
end

local listen_options = {
  pre_fork              = config.fork.pre,
  min_fork              = config.fork.min,
  max_fork              = config.fork.max,
  fork_delay            = config.fork.delay,
  fork_error_delay      = config.fork.error_delay,
  exit_delay            = config.fork.exit_delay,
  idle_timeout          = config.fork.idle_timeout,
  memory_limit          = config.fork.memory_limit,
  min_requests_per_fork = config.fork.min_requests,
  max_requests_per_fork = config.fork.max_requests,
  http_options          = config.http_options
}

if config.ipv6 then
  local host = config.localhost and "::1" or "::"
  listen_options[#listen_options+1] = { proto = "tcp", host = host, port = config.port }
end
if config.ipv6 ~= "only" then
  local host = config.localhost and "127.0.0.1" or "0.0.0.0"
  listen_options[#listen_options+1] = { proto = "tcp", host = host, port = config.port }
end

request.set_404_route{ module = 'index', view = '404' }

request.set_absolute_baseurl(config.absolute_base_url)

-- TODO remove style cache

listen(listen_options)

listen{
  {
    proto = "main",
    name = "process_event_stream",
    handler = function(poll)
      Event:process_stream(poll)
    end    
  }
}

listen{
  {
    proto = "interval",
    name  = "send_pending_notifications",
    delay = 5,
    handler = function()
      while true do
        if not Newsletter:send_next_newsletter() then
          break
        end
        moonbridge_io.poll(nil, nil, 1)
      end
      while true do
        if not InitiativeForNotification:notify_next_member() then
          break
        end
        moonbridge_io.poll(nil, nil, 1)
      end
    end
  },
  min_fork = 1,
  max_fork = 1
}

if config.firstlife_groups then
  assert(loadcached(encode.file_path(WEBMCP_BASE_PATH, "lib", "firstlife", "groups.lua")))()
  listen{
    {
      proto = "interval",
      name  = "mirror_firstlife_groups",
      delay = 5,
      handler = function()
        firstlife_mirror_groups()
      end
    },
    min_fork = 1,
    max_fork = 1
  }
end

execute.inner()

