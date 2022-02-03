local skip_survey = param.get("skip_survey")

local survey = Survey:get_open()

local survey_member = SurveyMember:by_pk(survey.id, app.session.member_id)

if survey_member and not skip_survey then
  return true
end

local secret_length = 24
local secret_alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
local secret_purposes = { "oauth", "_other" }
for idx, purpose in ipairs(secret_purposes) do
  secret_purposes[purpose] = idx
end

local function random_string(length_multiplier)
  return multirand.string(
    secret_length * (length_multiplier or 1),
    secret_alphabet
  )
end

if not survey_member then
  survey_member = SurveyMember:new()
  survey_member.survey_id = survey.id
  survey_member.member_id = app.session.member_id
end

if skip_survey then
  local answer_set = survey_member.answer_set
  if answer_set then
    survey_member.survey_answer_set_ident = nil
    survey_member:save()
    answer_set:destroy()
  end
  survey_member.rejected = 'now'
else
  local answer_set = SurveyAnswerSet:new()
  answer_set.ident = random_string()
  answer_set.survey_id = survey.id
  local verification = Verification:new_selector()
    :add_where{ "verified_member_id = ?", app.session.member_id }
    :optional_object_mode()
    :exec()
  if verification then
    answer_set.data = verification.request_data
    answer_set.data.name = nil
    answer_set.data.email = nil
  end
  answer_set:save()
  survey_member.survey_answer_set_ident = answer_set.ident
end

survey_member:save()

if skip_survey then
  return "skip_survey"
end

return true

