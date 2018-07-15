local issues = param.get("issues", "table")


local fields = { "id", "area_id", "policy_id", "admin_notice", "external_reference", "state", "phase_finished", "created", "accepted", "half_frozen", "fully_frozen", "closed", "cleaned", "min_admission_time", "max_admission_time", "discussion_time", "verification_time", "voting_time", "latest_snapshot_id", "admission_snapshot_id", "half_freeze_snapshot_id", "full_freeze_snapshot_id", "population", "voter_count", "status_quo_schulze_rank" }

local r = json.array()

for i, issue in ipairs(issues) do
  local ir = json.object()
  for j, field in ipairs(fields) do
    local value = issue[field]
    if value == nil then
      value = json.null
    else
      value = tostring(value)
    end
    ir[field] = value
  end
  r[#r+1] = ir
end

return r
