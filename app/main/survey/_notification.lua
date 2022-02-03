if not app.session.member then
  return
end
local survey = Survey:get_open()

if not survey then
  return
end

local survey_member = SurveyMember:by_pk(survey.id, app.session.member_id)

if not survey_member or survey_member.answer_set and not survey_member.finished then
  slot.select("motd", function()
    ui.container{ attr = { class = "mdl-card mdl-card__fullwidth mdl-shadow--2dp" }, content = function()
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
        ui.form{
          module = "survey", action = "participate",
          routing = {
            ok = { mode = "redirect", module = "survey", view = "participate" },
            error = { mode = "forward", module = "survey", view = "participate" },
            skip_survey = { mode = "redirect", module = "index", view = "index" },
          },
          content = function()
            ui.heading{ content = survey.title }
            ui.container{ content = function()
              slot.put(survey.text)
            end }
            slot.put("<br>")
            local start_text = _"Start survey"
            local cancel_text = _"I don't want to particiapte"
            if survey_member then
              start_text = _"Continue survey"
              cancel_text = _"Cancel survey"
            end
            ui.tag{
              tag = "input",
              attr = {
                type = "submit",
                class = "mdl-button mdl-js-button mdl-button--raised mdl-button--colored",
                value = start_text
              },
              content = ""
            }
            slot.put(" &nbsp; ")
            ui.tag{
              tag = "input",
              attr = {
                type = "submit",
                name = "skip_survey",
                class = "mdl-button mdl-js-button",
                value = cancel_text
              },
              content = ""
            }
          end
        }
      end }
    end }
  end)
end

