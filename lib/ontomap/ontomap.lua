function _G.ontomap_get_instances(event)
  if true then return {} end 
  local url = config.ontomap.base_url .. "instances/Issue?geometries=true&descriptions=true"
  print("OnToMap>>")
  
  local output, err, status = extos.pfilter(doc, "curl", "-X", "GET", "-H", "Content-Type: application/json", "--cert", config.ontomap.client_cert_file, "-d", "@-", url)
  print(output)
  
  local data = json.import(output)
  
  if not data then
    return {}
  end

  if data.type ~= "FeatureCollection" or not data.features then
    return {}
  end
  
  local instances = {}
  for i, feature in ipairs(data.features) do
    if feature.geometry then
      table.insert(instances, {
        application = feature.applicationName,
        title = feature.hasName,
        description = slot.use_temporary(function()
          ui.link{ external = feature.properties.external_url, text = feature.properties.hasName or "" }
          ui.container{ content = feature.hasDescription }
        end),
        lon = feature.geometry.coordinates[1],
        lat = feature.geometry.coordinates[2],
        label = "IMC" .. feature.properties.hasID,
        type = "Improve My City"
      })
      print(feature.applicationName, feature.properties.hasName, feature.properties.hasDescription)
    end
  end
  return instances

end


local function new_log_event(event, actor, activity_type)
  local e = json.object{
    activity_type = activity_type,
    activity_objects = json.array(),
    references = json.array(),
    visibility_details = json.array(),
    details = json.object()
  }
  e.actor = actor
  e.timestamp = math.floor(event.occurrence_epoch * 1000)
  return e
end

local function new_activity_object(attr)
  return json.object{
    type = "Feature",
    geometry = attr.geometry or json.null,
    properties = json.object{
      hasType = attr.type,
      external_url = attr.url
    }
  }
end

local function new_reference_object(url, application, type)
  return json.object{
    application = application or config.ontomap.application_ident,
    external_url = url,
    type = type
  }
end

local function log_to_ontomap(log_events)
  if json.type(log_events) == "object" then
    log_events = json.array{ log_events }
  end
  for i, log_event in ipairs(log_events) do
    if #(log_event.activity_objects) == 0 then
      log_event.activity_objects = nil
    end
    if #(log_event.references) == 0 then
      log_event.references = nil
    end
    if #(log_event.visibility_details) == 0 then
      log_event.visibility_details = nil
    end
    if not (next(log_event.details)) then -- TODO
      log_event.details = nil
    end
  end

  local doc = json.export(json.object{
    event_list = log_events
  }, "  ")
    
  local url = config.ontomap.base_url .. "logger/events"
  print("OnToMap<<")
  print(doc)
  
  local output, err, status = extos.pfilter(doc, "curl", "-X", "POST", "-H", "Content-Type: application/json", "--cert", config.ontomap.client_cert_file, "-d", "@-", url)
  
  print("---------")
  print(output)
  print("---------")
  
  if err then
    -- TODO log error
  end
end

local function url_for(relation, id)
  return config.absolute_base_url .. relation .. "/show/" .. id .. ".html"
end


local function unit_updated(event, event_type)
  local log_event = new_log_event(event, 0, event_type == "created" and "object_created" or "object_updated")
  table.insert(log_event.activity_objects, new_activity_object{
    type = "unit",
    url = url_for("unit", event.unit_id)
  })
  log_event.details.active = event.unit.active
  log_event.details.name = event.unit.name
  log_event.details.description = event.unit.description
  log_event.details.external_reference = event.unit.external_reference
  log_event.details.region = event.unit.region
  log_to_ontomap(log_event)
end

local function area_updated(event, event_type)
  local log_event = new_log_event(event, 0, event_type == "created" and "object_created" or "object_updated")
  table.insert(log_event.activity_objects, new_activity_object{
    type = "area",
    url = url_for("area", event.area_id)
  })
  table.insert(log_event.references, new_reference_object(
    url_for("unit", event.area.unit_id)
  ))
  log_event.details.active = event.area.active
  log_event.details.name = event.area.name
  log_event.details.description = event.area.description
  log_event.details.external_reference = event.area.external_reference
  log_event.details.region = event.area.region
  log_to_ontomap(log_event)
end

local function policy_updated(event, event_type)
  local log_event = new_log_event(event, 0, event_type == "created" and "object_created" or "object_updated")
  table.insert(log_event.activity_objects, new_activity_object{
    type = "policy",
    url = url_for("policy", event.policy_id)
  })
  log_event.details.active = event.policy.active
  log_event.details.name = event.policy.name
  log_event.details.description = event.policy.description
  log_to_ontomap(log_event)
end

local mapper = {
  
  unit_created = function(event)
    unit_updated(event, "created") 
  end,

  unit_updated = function(event)
    unit_updated(event, "updated") 
  end,
  
  area_created = function(event)
    area_updated(event, "created")
  end,

  area_updated = function(event)
    area_updated(event, "updated")
  end,

  policy_created = function(event)
    policy_updated(event, "created")
  end,
  
  policy_updated = function(event)
    policy_updated(event, "updated")
  end,

  issue_state_changed = function(event)
    local log_event = new_log_event(event, 0, "issue_status_updated")
    table.insert(log_event.references, new_reference_object(
      url_for("issue", event.issue_id)
    ))
    log_event.details.new_issue_state = event.state
    log_to_ontomap(log_event)
  end,

  initiative_created_in_new_issue = function(event)
    local log_events = json.array()
  
    local log_event = new_log_event(event, 0, "object_created")
    table.insert(log_event.activity_objects, new_activity_object{
      type = "issue",
      url = url_for("issue", event.issue_id)
    })
    table.insert(log_event.references, new_reference_object(
      url_for("policy", event.issue.policy_id)
    ))
    log_event.details.new_issue_state = event.state
    table.insert(log_events, log_event)

    local log_event = new_log_event(event, event.member_id, "object_created")

    local location = event.initiative.location
    if location and location.marker_link then
      local marker_link = location.marker_link
      location.marker_link = nil
      table.insert(log_event.references, new_reference_object(
        marker_link, config.firstlife.application_ident, "BELONGS_TO"
      ))
    end 
    
    local activity_object = new_activity_object{
      type = "initiative",
      url = url_for("initiative", event.initiative_id),
      geometry = location
    }
    activity_object.properties.name = event.initiative.name
    table.insert(log_event.activity_objects, activity_object)
    table.insert(log_event.references, new_reference_object(
      url_for("issue", event.issue_id)
    ))
    table.insert(log_events, log_event)

    log_to_ontomap(log_events)
  end,

  initiative_created_in_existing_issue = function(event)
    local log_event = new_log_event(event, event.member_id, "object_created")
    local location = event.initiative.location
    if location and location.marker_link then
      local marker_link = location.marker_link
      location.marker_link = nil
      table.insert(log_event.references, new_reference_object(
        marker_link, config.firstlife.application_ident, "BELONGS_TO"
      ))
    end 
    local activity_object = new_activity_object{
      type = "initiative",
      url = url_for("initiative", event.initiative_id),
      geometry = location
    }
    activity_object.properties.name = event.initiative.name
    table.insert(log_event.activity_objects, activity_object)
    table.insert(log_event.references, new_reference_object(
      url_for("issue", event.issue_id)
    ))
    log_to_ontomap(log_event)
  end,

  initiative_revoked = function(event)
    -- TODO -> which activity?
  end,

  new_draft_created = function(event)
    local log_event = new_log_event(event, event.member_id, "object_updated")
    table.insert(log_event.activity_objects, new_activity_object{
      type = "initiative",
      url = url_for("initiative", event.issue_id)
    })
    table.insert(log_event.references, new_reference_object(
      url_for("issue", event.issue_id)
    ))
    log_event.details.name = event.initiative.name
    log_event.details.location = event.initiative.current_draft.location
    log_to_ontomap(log_event)
  end,

  interest = function(event)
    local activity_type = event.boolean_value and "interest_added" or "interest_removed"
    local log_event = new_log_event(event, event.member_id, activity_type)
    table.insert(log_event.references, new_reference_object(
      url_for("issue", event.issue_id)
    ))
    log_to_ontomap(log_event)
  end,

  initiator = function(event)
    local activity_type = event.boolean_value and "initiator_added" or "initiator_removed"
    local log_event = new_log_event(event, event.member_id, activity_type)
    table.insert(log_event.references, new_reference_object(
      url_for("initiative", event.initiative_id)
    ))
    log_to_ontomap(log_event)
  end,

  support = function(event)
    local activity_type = event.boolean_value and "support_added" or "support_removed"
    local log_event = new_log_event(event, event.member_id, activity_type)
    table.insert(log_event.references, new_reference_object(
      url_for("initiative", event.initiative_id)
    ))
    log_event.details.draft_id = event.draft_id
    log_to_ontomap(log_event)
  end,

  support_updated = function(event)
    local log_event = new_log_event(event, event.member_id, "support_updated")
    table.insert(log_event.references, new_reference_object(
      url_for("initiative", event.initiative_id)
    ))
    log_event.details.draft_id = event.draft_id
    log_to_ontomap(log_event)
  end,

  suggestion_created = function(event)
    local log_event = new_log_event(event, event.member_id, "object_created")
    table.insert(log_event.activity_objects, new_activity_object{
      type = "suggestion",
      url = url_for("suggestion", event.suggestion_id)
    })
    table.insert(log_event.references, new_reference_object(
      url_for("initiative", event.initiative_id)
    ))
    log_to_ontomap(log_event)
  end,

  suggestion_removed = function(event)
    local log_event = new_log_event(event, 0, "object_removed")
    table.insert(log_event.activity_objects, new_activity_object{
      type = "suggestion",
      url = url_for("suggestion", event.suggestion_id)
    })
    table.insert(log_event.references, new_reference_object(
      url_for("initiative", event.initiative_id)
    ))
    log_to_ontomap(log_event)
  end,

  suggestion_rated = function(event)
    local log_event = new_log_event(event, event.member_id, "suggestion_rated")
    table.insert(log_event.references, new_reference_object(
      url_for("suggestion", event.suggestion_id)
    ))
    log_event.details.degree = event.numeric_value
    log_event.details.fulfilled = event.boolean_value or json.null
    log_to_ontomap(log_event)
  end,

  delegation = function(event)
    -- TODO
  end,

  member_activated = function(event)
    local log_event = new_log_event(event, event.member_id, "account_registered")
    log_to_ontomap(log_event)
  end,

  member_removed = function(event)
    -- TODO -> which activity to log?
  end,

  member_active = function(event)
    -- TODO -> which activity to log?
  end,

  member_name_updated = function(event)
    local log_event = new_log_event(event, event.member_id, "screen_name_changed")
    log_event.details.screen_name = event.text_value
    log_to_ontomap(log_event)
  end,

  member_profile_updated = function(event)
    local log_event = new_log_event(event, event.member_id, "profile_updated")
    log_to_ontomap(log_event)
  end,

  member_image_updated = function(event)
    local log_event = new_log_event(event, event.member_id, "avatar_changed")
    log_to_ontomap(log_event)
  end,

  contact = function(event)
    local activity_type = event.boolean_value and "contact_published" or "contact_unpublished"
    local log_event = new_log_event(event, event.member_id, activity_type)
    log_event.details.other_member_id = event.other_member_id
    log_to_ontomap(log_event)
  end

}

function _G.ontomap_log_event(event)

  if mapper[event.event] then
    local e = Event:new_selector()
      :add_where{ "id = ?", event.id }
      :add_field("extract(epoch from occurrence)", "occurrence_epoch")
      :optional_object_mode()
      :exec()
    if e then
      mapper[event.event](e)
    end
  end


end
