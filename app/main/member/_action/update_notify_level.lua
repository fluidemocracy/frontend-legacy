app.session.member.disable_notifications = param.get("disable_notifications") == "true" and true or false
IgnoredArea:destroy_by_member_id(app.session.member_id)
app.session.member:save()
