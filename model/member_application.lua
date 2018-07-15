MemberApplication = mondelefant.new_class()
MemberApplication.table = 'member_application'

MemberApplication:add_reference{
  mode          = 'm1',
  to            = "SystemApplication",
  this_key      = 'system_application_id',
  that_key      = 'id',
  ref           = 'system_application'
}

function MemberApplication:get_selector_by_member_id_and_system_application_id(member_id, system_application_id)
  local selector = self:new_selector()
  selector:add_where{ "member_id = ?", member_id }
  selector:add_where{ "system_application_id = ?", system_application_id }
  selector:optional_object_mode()
  return selector
end

function MemberApplication:by_member_id_and_system_application_id(member_id, system_application_id)
  local member_application = self:get_selector_by_member_id_and_system_application_id(member_id, system_application_id)
    :optional_object_mode()
    :exec()
  return member_application
end

function MemberApplication:get_selector_by_member_id_and_domain(member_id, domain)
  local selector = self:new_selector()
  selector:add_where{ "member_id = ?", member_id }
  selector:add_where{ "domain = ?", domain }
  selector:optional_object_mode()
  return selector
end

function MemberApplication:by_member_id_and_domain(member_id, domain)
  local member_application = self:get_selector_by_member_id_and_domain(member_id, domain)
    :optional_object_mode()
    :exec()
  return member_application
end

function MemberApplication:by_member_id(member_id)
  local member_applications = self:new_selector()
    :add_where{ "member_id = ?", member_id }
    :exec()
  return member_applications
end

function MemberApplication:by_member_id_with_domain(member_id)
  local member_applications = self:new_selector()
    :add_where{ "member_id = ?", member_id }
    :add_where( "domain NOTNULL" )
    :exec()
  return member_applications
end

function MemberApplication:by_member_id_and_origin(member_id, origin)
  local domain = string.match(string.lower(origin), "^https://(.+)")
  if not domain then
    return
  end
  local member_application = self:get_selector_by_member_id_and_domain(member_id, domain)
    :optional_object_mode()
    :exec()
  return member_application
end
