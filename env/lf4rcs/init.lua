function lf4rcs.init()
  Event.add_handler(function(event)
    lf4rcs.notification_handler(event)
  end)
  config.render_external_reference = {
    draft = lf4rcs.render_draft_reference,
    initiative = lf4rcs.render_initiative_reference
  }
end

