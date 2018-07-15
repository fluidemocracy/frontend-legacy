SystemApplicationRedirectUri = mondelefant.new_class()
SystemApplicationRedirectUri.table = 'system_application_redirect_uri'


function SystemApplicationRedirectUri:by_pk(system_application_id, redirect_uri)
  local system_application_redirect_uri = self:new_selector()
    :add_where{ "system_application_id = ?", system_application_id }
    :add_where{ "redirect_uri = ?", redirect_uri }
    :optional_object_mode()
    :exec()
  return system_application_redirect_uri
end
