Survey = mondelefant.new_class()
Survey.table = 'survey'

Survey:add_reference{
  mode          = '1m',
  to            = "SurveyQuestion",
  this_key      = 'id',
  that_key      = 'survey_id',
  ref           = 'questions',
  back_ref      = 'survey',
  default_order = 'position'
}


local new_selector = Survey.new_selector

function Survey:new_selector()
  local selector = new_selector(self)
  selector:add_field("CASE WHEN (open_until NOTNULL AND open_until > now()) THEN open_until - now() ELSE NULL END", "time_left")
  return selector
end

function Survey:get_open()
  return self:new_selector()
    :add_where("open_from < now() and open_until > now()")
    :optional_object_mode()
    :exec()
end

function Survey.object_get:open()
  if self.open_from < atom.timestamp:get_current() and self.open_until > atom.timestamp:get_current() then
    return true
  end
  return false
end
