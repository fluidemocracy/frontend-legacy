SurveyAnswer = mondelefant.new_class()
SurveyAnswer.table = 'survey_answer'

function SurveyAnswer:by_pk(survey_answer_set_ident, member_id)
  return self:new_selector()
    :add_where{ "survey_answer_set_ident = ?", survey_answer_set_ident }
    :add_where{ "survey_question_id = ?", question_id }
    :optional_object_mode()
    :exec()
end
