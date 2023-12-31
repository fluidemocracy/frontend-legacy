local policy = Policy:by_id(param.get_id()) or Policy:new()

param.update(
  policy, 
  "index", "name", "description", "active", 
  "min_admission_time", "max_admission_time", "discussion_time", "verification_time", "voting_time", 
  "issue_quorum", "issue_quorum_num", "issue_quorum_den",
  "initiative_quorum", "initiative_quorum_num", "initiative_quorum_den", 
  "direct_majority_num", "direct_majority_den", "direct_majority_positive", "direct_majority_non_negative",
  "indirect_majority_num", "indirect_majority_den", "indirect_majority_strict", "indirect_majority_positive", "indirect_majority_non_negative",
  "no_reverse_beat_path", "no_multistage_majority", "polling"
)

if param.get("direct_majority_strict") == "1" then 
  policy.direct_majority_strict = true 
else 
  policy.direct_majority_strict = false 
end

if policy.min_admission_time == "" then policy.min_admission_time = nil end
if policy.max_admission_time == "" then policy.max_admission_time = nil end
if policy.discussion_time == "" then policy.discussion_time = nil end
if policy.verification_time == "" then policy.verification_time = nil end
if policy.voting_time == "" then policy.voting_time = nil end

policy:save()
