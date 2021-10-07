SurveyMember = mondelefant.new_class()
SurveyMember.table = 'survey_member'

SurveyMember:add_reference{
  mode          = '11',
  to            = "SurveyAnswerSet",
  this_key      = 'survey_answer_set_ident',
  that_key      = 'ident',
  ref           = 'answer_set',
  back_ref      = 'member'
}

function SurveyMember:by_pk(survey_id, member_id)
  return self:new_selector()
    :add_where{ "survey_id = ?", survey_id }
    :add_where{ "member_id = ?", member_id }
    :optional_object_mode()
    :exec()
end
