EventProcessed = mondelefant.new_class()
EventProcessed.table = 'event_processed'

function EventProcessed:get_last_id()
  
  local event_processed = self:new_selector()
    :optional_object_mode()
    :for_update()
    :exec()
    
  local last_event_id = 0
  if event_processed then
    last_event_id = event_processed.event_id
  end
  
  return last_event_id
  
end

function EventProcessed:set_last_id(id)
  db:query{ "INSERT INTO event_processed (event_id) VALUES (?) ON CONFLICT ((1)) DO UPDATE SET event_id = EXCLUDED.event_id", id }
end
