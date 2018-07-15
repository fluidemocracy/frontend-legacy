SystemApplication = mondelefant.new_class()
SystemApplication.table = 'system_application'


function SystemApplication:by_client_id(client_id)
  local system_application = self:new_selector()
    :add_where{ "client_id = ?", client_id }
    :optional_object_mode()
    :exec()
  return system_application
end

function SystemApplication:by_origin(origin)
  local system_applications = self:new_selector()
    :set_distinct()
    :left_join("system_application_redirect_uri", nil, "system_application_redirect_uri.system_application_id = system_application.id")
    :add_where{ "lower(regexp_replace(system_application.default_redirect_uri, '^([^:]+://[^/]+)/.*', E'\\\\1', 'i')) = lower(?) OR lower(regexp_replace(system_application_redirect_uri.redirect_uri, '^([^:]+://[^/]+)/.*', E'\\\\1', 'i')) = lower(?)", origin, origin }
    :exec()
  return system_applications
end

function SystemApplication:get_all()
  local system_application = self:new_selector()
    :exec()
  return system_application
end


