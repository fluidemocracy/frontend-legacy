SurveyQuestion = mondelefant.new_class()
SurveyQuestion.table = 'survey_question'

SurveyQuestion:add_reference{
  mode          = 'm1',
  to            = "Survey",
  this_key      = 'survey_id',
  that_key      = 'id',
  ref           = 'survey',
}
