local id = param.get("question_id", atom.integer)

local question = SurveyQuestion:by_id(id)

local survey = Survey:get_open()

if question.survey_id ~= survey.id then
  slot.put_into("error", _"Internal error 2")
  return false
end

if not question or not question.survey.open then
  slot.put_into("error", _"Internal error 3")
  return false
end

local survey_member = SurveyMember:by_pk(question.survey.id, app.session.member_id)
if not survey_member then
  return execute.view { module = "index", view = "404" }
end

local answer_set = survey_member.answer_set
if not answer_set then
  return execute.view { module = "index", view = "404" }
end

local answer = SurveyAnswer:by_pk(answer_set.ident, question.id)
if not answer then
  answer = SurveyAnswer:new()
  answer.survey_answer_set_ident = answer_set.ident
  answer.survey_question_id = question.id
end

if question.answer_type == "radio" then
  local given_answer = param.get("answer")
  if not given_answer then
    slot.put_into("error", _"Please choose an option!")
    return false
  end
  local answer_valid = false
  for i, answer_option in ipairs(question.answer_options) do
    if given_answer == answer_option then
      answer_valid = true
    end
  end
  if not answer_valid then
    slot.put_into("error", _"Internal error 1")
    return false
  end
  answer.answer = given_answer

elseif question.answer_type == "checkbox" then
  local answers = json.array()
  for i, answer_option in ipairs(question.answer_options) do
    local answer = param.get("answer_" .. answer_option)
    if answer then
      table.insert(answers, answer)
    end
  end
  answer.answer = answers
end

answer:save()

local question
local answers_by_question_id = {}
for i, answer in ipairs(answer_set.answers) do
  answers_by_question_id[answer.survey_question_id] = answer
end
for i, q in ipairs(survey.questions) do
  if not question and not answers_by_question_id[q.id] then
    question = q
  end
end

if not question then
  survey_member.survey_answer_set_ident = nil
  survey_member.finished = 'now'
  survey_member:save()
end

return true
