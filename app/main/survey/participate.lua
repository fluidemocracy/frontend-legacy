local survey = Survey:get_open()
if not survey then
  return execute.view { module = "index", view = "404" }
end

local survey_member = SurveyMember:by_pk(survey.id, app.session.member_id)
if not survey_member then
  return execute.view { module = "index", view = "404" }
end

local question
local question_number = #survey.questions

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
        question_number = i - 1
      end
    end
  end
end

ui.title(survey.title)
ui.grid{ content = function()
  ui.cell_main{ content = function()

    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp survey" }, content = function()
      ui.container{ attr = { class = "mdl-card__title" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = function()
          if survey_member.finished then
            slot.put(survey.finished_title)
          else
            ui.tag{ tag = "span", content = question.question }
            ui.tag{ attr = { class = "survey_counter" }, content = (question_number + 1) .. " / " .. #survey.questions }
          end
        end }
      end }
      slot.put('<div id = "progressbar1" style="width: 100%;" class = "mdl-progress mdl-js-progress"></div>')
      
      ui.script{ script = [[
        document.querySelector('#progressbar1').addEventListener('mdl-componentupgraded', 
            function() {
            this.MaterialProgress.setProgress(]] .. question_number / #survey.questions * 100 .. [[);
         }); 
      
      ]] }
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
            slot.put("<br>")
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
                end

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
                            class = "mdl-checkbox__input",
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
          }
        end
      end }
    end }
  end }
end }
