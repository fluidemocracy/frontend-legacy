app.session.member.disable_notifications = param.get("disable_notifications") == "true" and true or false
app.session.member:save()
