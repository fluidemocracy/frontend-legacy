ui.heading{ level = 1, content = _"Surveys" }

local surveys = Survey:get_open()

for i, survey in ipairs(surveys) do

  ui.container{ content = function()
  
    ui.link{ module = "survey", view = "participate", id = survey.id, content = survey.name }
    
    ui.container{ content = survey.description }
  
  end }

end
