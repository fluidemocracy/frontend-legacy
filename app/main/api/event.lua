slot.set_layout(nil, "application/json")

local r = json.object{
  result = json.array{}
}

local selector = Event:new_selector()

local member_id = param.get("member_id", atom.integer)
local other_member_id = param.get("member_id", atom.integer)
local scope = param.get("scope")
local issue_id = param.get("issue_id", atom.integer)
local state = param.get("state")
local initiative_id = param.get("initiative_id", atom.integer)

local include_members = param.get("include_members", atom.boolean)
local include_other_members = param.get("include_other_members", atom.boolean)
local include_profile = param.get("include_profile", atom.boolean)
local include_issues = param.get("include_issues", atom.boolean)
local include_initiatives = param.get("include_initiatives", atom.boolean)
local include_drafts = param.get("include_drafts", atom.boolean)
local include_suggestions = param.get("include_suggestions", atom.boolean)

if member_id then
  selector:add_where{ "member_id = ?", member_id }
end

if other_member_id then
  selector:add_where{ "other_member_id = ?", other_member_id }
end

if scope then
  selector:add_where{ "scope = ?", scope }
end

if issue_id then
  selector:add_where{ "issue_id = ?", issue_id }
end

if scope then
  selector:add_where{ "scope = ?", scope }
end

if initiative_id then
  selector:add_where{ "initiative_id = ?", initiative_id }
end

selector:add_order_by("id DESC")

local events = selector:exec()

local member_ids = {}
local issue_ids = {}
local initiative_ids = {}
local draft_ids = {}
local suggestion_ids = {}

for i, event in ipairs(events) do
  local e = json.object()
  e.id = event.id
  e.occurrence = format.timestamp(event.occurrence)
  e.event = event.event
  e.member_id = event.member_id
  e.other_member_id = event.other_member_id
  e.scope = event.scope
  e.issue_id = event.issue_id
  e.state = event.state
  e.initiative_id = event.initiative_id
  e.draft_id = event.draft_id
  e.suggestion_id = event.suggestion_id
  e.value = event.value
  if include_members and e.member_id then
    member_ids[e.member_id] = true
  end
  if include_other_members and e.other_member_id then
    member_ids[e.member_id] = true
  end
  if include_issues and e.issue_id then
    issue_ids[e.issue_id] = true
  end
  if include_initiatives and e.initiative_id then
    initiative_ids[e.initiative_id] = true
  end
  if include_drafts and e.draft_id then
    draft_ids[e.draft_id] = true
  end
  if include_suggestions and e.suggestion_id then
    suggestion_ids[e.suggestion_id] = true
  end
  r.result[#r.result+1] = e
end

function util.keys_to_array(tbl)
  local r = {}
  for k, v in pairs(tbl) do
    r[#r+1] = k
  end
  return r
end

function util.array_to_json_object(tbl, key)
  local r = json.object()
  for i, v in ipairs(tbl) do
    r[v[key]] = v
  end
  return r
end

if next(member_ids) then
  local members = Member:by_ids(util.keys_to_array(member_ids))
  r.members = util.array_to_json_object(
    execute.chunk{ module = "api", chunk = "_member", params = { members = members, include_profile = include_profile } },
    "id"
  )
  if r.members == false then
    return
  end
end

if next(issue_ids) then
  local issues = Issue:by_ids(util.keys_to_array(issue_ids))
  r.issues = util.array_to_json_object(
    execute.chunk{ module = "api", chunk = "_issue", params = { issues = issues } },
    "id"
  )
  if r.issues == false then
    return
  end
end


slot.put_into("data", json.export(r))
