local survey = Survey:get_open()
if not survey then
  return execute.view { module = "index", view = "404" }
end

local survey_member = SurveyMember:by_pk(survey.id, app.session.member_id)
if not survey_member then
  return execute.view { module = "index", view = "404" }
end

local question

if survey_member then
  local answer_set = survey_member.answer_set
  if answer_set then
    local answers_by_question_id = {}
    for i, answer in ipairs(answer_set.answers) do
      answers_by_question_id[answer.survey_question_id] = answer
    end
    for i, q in ipairs(survey.questions) do
      if not question and not answers_by_question_id[q.id] then
        question = q
      end
    end
  end
end

ui.title(survey.title)
ui.grid{ content = function()
  ui.cell_main{ content = function()

    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp survey" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = question.question }
      end }
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
        if survey_member.finished then
          ui.container{ content = function()
            slot.put(survey.finished_text)
          end }
          slot.put("<br>")
          ui.link{
            attr = { class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored" },
            module = "index", view = "index", content = _"Go to start page"
          }
          return
        else
          if question.description then
            ui.container{ content = question.description }
          end
          ui.form{
            module = "survey", action = "answer",
            routing = {
              ok = { mode = "redirect", module = "survey", view = "participate" },
              error = { mode = "forward", module = "survey", view = "participate" },
            },
            content = function()
              ui.field.hidden{ name = "question_id", value = question.id }

              if question.answer_type == "radio" then
                for i, answer_option in ipairs(question.answer_options) do
                  ui.container{ content = function()
                    ui.tag{ tag = "label", attr = {
                        class = "mdl-radio mdl-js-radio mdl-js-ripple-effect",
                        ["for"] = "answer_" .. i
                      },
                      content = function()
                        ui.tag{
                          tag = "input",
                          attr = {
                            id = "answer_" .. i,
                            class = "mdl-radio__button",
                            type = "radio",
                            name = "answer",
                            value = answer_option,
                            checked = param.get("answer") == answer_option and "checked" or nil,
                          }
                        }
                        ui.tag{
                          attr = { class = "mdl-radio__label", ['for'] = "answer_" .. i },
                          content = answer_option
                        }
                      end
                    }
                  end }

              elseif question.answer_type == "checkbox" then
                for i, answer_option in ipairs(question.answer_options) do
                  ui.container{ content = function()
                    ui.tag{ tag = "label", attr = {
                        class = "mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect",
                        ["for"] = "answer_" .. i
                      },
                      content = function()
                        ui.tag{
                          tag = "input",
                          attr = {
                            id = "answer_" .. i,
                            class = "mdl-checkbox__button",
                            type = "checkbox",
                            name = "answer_" .. answer_option,
                            value = "1",
                            checked = param.get("answer_" .. answer_option) and "checked" or nil,
                          }
                        }
                        ui.tag{
                          attr = { class = "mdl-checkbox__label", ['for'] = "answer_" .. i },
                          content = answer_option
                        }
                      end
                    }
                  end }
                end

                slot.put("<br>")
                ui.tag{
                  tag = "input",
                  attr = {
                    type = "submit",
                    class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored",
                    value = _"Next step"
                  },
                  content = ""
                }
              end
            end
          }
        end
      end }
    end }
  end }
end }
