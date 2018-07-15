Agent= mondelefant.new_class()
Agent.table = 'agent'
Agent.primary_key = { "controlled_id", "controller_id" }

Agent:add_reference{
  mode          = 'm1',
  to            = "Member",
  this_key      = 'controller_id',
  that_key      = 'id',
  ref           = 'controller',
}

Agent:add_reference{
  mode          = 'm1',
  to            = "Member",
  this_key      = 'controlled_id',
  that_key      = 'id',
  ref           = 'controllee',
}

function Agent:by_pk(controlled_id, controller_id)
  return self:new_selector()
    :add_where{ "controlled_id = ?", controlled_id }
    :add_where{ "controller_id = ?", controller_id }
    :optional_object_mode()
    :exec()
end
