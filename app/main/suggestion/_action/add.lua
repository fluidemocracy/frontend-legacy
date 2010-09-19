local tmp = db:query({ "SELECT text_entries_left FROM member_contingent_left WHERE member_id = ?", app.session.member.id }, "opt_object")
if tmp and tmp.text_entries_left and tmp.text_entries_left < 1 then
  slot.put_into("error", _"Sorry, you have reached your personal flood limit. Please be slower...")
  return false
end

local name = param.get("name")
local name = util.trim(name)

if #name < 3 then
  slot.put_into("error", _"This title is really too short!")
  return false
end

local suggestion = Suggestion:new()

suggestion.author_id = app.session.member.id
suggestion.name = name
param.update(suggestion, "description", "initiative_id")
suggestion:save()

-- TODO important m1 selectors returning result _SET_!
local issue = suggestion.initiative:get_reference_selector("issue"):for_share():single_object_mode():exec()

if issue.closed then
  slot.put_into("error", _"This issue is already closed.")
  return false
elseif issue.half_frozen then 
  slot.put_into("error", _"This issue is already frozen.")
  return false
end

local opinion = Opinion:new()

opinion.suggestion_id = suggestion.id
opinion.member_id     = app.session.member.id
opinion.degree        = param.get("degree", atom.integer)
opinion.fulfilled     = false

opinion:save()

slot.put_into("notice", _"Your suggestion has been added")