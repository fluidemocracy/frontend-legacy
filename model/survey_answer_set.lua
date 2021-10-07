SurveyAnswerSet = mondelefant.new_class()
SurveyAnswerSet.table = 'survey_answer_set'
SurveyAnswerSet.primary_key = "ident"

SurveyAnswerSet:add_reference{
  mode          = '1m',
  to            = "SurveyAnswer",
  this_key      = 'ident',
  that_key      = 'survey_answer_set_ident',
  ref           = 'answers',
  back_ref      = 'answer_set'
}
