Snapshot = mondelefant.new_class()
Snapshot.table = 'snapshot'
Snapshot.primary_key = "id"

function Snapshot:latest_by_issue_id(issue_id)
  return self:new_selector()
    :add_where{ "issue_id = ?", issue_id }
    :add_order_by("id DESC")
    :limit(1)
    :optional_object_mode()
    :exec()
end
