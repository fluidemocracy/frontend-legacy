local function firstlife_mirror_group_users(unit)
  local url = config.firstlife_groups.api_base_url .. "v6/fl/Things/" .. unit.attr.firstlife_id .. "/participants"
  
  local output, err, status = extos.pfilter(doc, "curl", "-X", "GET", "-H", "Content-Type: application/json", "-d", "@-", url)
  
  local data = json.import(output)

  local old_privileges_list = Privilege:new_selector()
    :add_where{ "unit_id = ?", unit.id }
    :exec()

  local old_privileges = {}
  for i, old_privilege in ipairs(old_privileges_list) do
    old_privileges[old_privilege.member_id] = old_privilege
  end

  local new_user_hash = {}

  for i, user in ipairs(data) do
    print("  Processing user ID " .. user.id)
    local user_id = tonumber(string.match(user.id, "^(.+)@"))
    new_user_hash[user_id] = user
    if old_privileges[user_id] then
      print("    Privilege entry exists")
    else
      print("    Creating new privilege")
      local privilege = Privilege:new()
      privilege.unit_id = unit.id
      privilege.member_id = user_id
      privilege.initiative_right = true
      privilege.voting_right = true
      privilege.weight = 1
      privilege:save()
    end
  end

  for i, old_privilege in ipairs(old_privileges_list) do
    if not new_user_hash[old_privilege.member_id] then
      print("  Destroying privilege for user ID " .. old_privilege.member_id)
      old_privilege:destroy()
    end
  end

end

function _G.firstlife_mirror_groups()


  local url = config.firstlife_groups.api_base_url .. "v6/fl/Things/search?types=CO3_ACA"
  
  local output, err, status = extos.pfilter(doc, "curl", "-X", "GET", "-H", "Content-Type: application/json", "-d", "@-", url)
  
  local data = json.import(output)

  if not data then return end
  if not data.things then return end
  if data.things.type ~= "FeatureCollection" then return end
  if not data.things.features then return end
  if json.type(data.things.features) ~= "array" then return end

  local units_new = {}

  for i, feature in ipairs(data.things.features) do
    print(feature.id, feature.properties.name)
    units_new[feature.id] = feature
  end

  local old_units_list = Unit:new_selector()
    :add_where("attr->'firstlife_id' NOTNULL")
    :exec()

  local old_units = {}

  for i, old_unit in ipairs(old_units_list) do
    old_units[old_unit.attr.firstlife_id] = old_unit
  end

  for id, unit_new in pairs(units_new) do
    local name_new = unit_new.properties.name
    local unit
    print("Processing unit ID " .. id .. " with name " .. name_new)
    if old_units[id] then
      unit = old_units[id]
      print("  Unit already exists")
      if old_units[id].name == name_new then
        print("  Name not changed")
      else
        print("  Name changed, updating")
        old_units[id].name = name_new
        old_units[id]:save()
      end
    else          
      print("  Creating as new unit")
      local u = Unit:new()
      u.name = name_new
      u.attr = json.object()
      u.attr.firstlife_id = id
      u:save()
      local area = Area:new()
      area.unit_id = u.id
      area.name = config.firstlife_groups.area_name
      area:save()
      local allowed_policy = AllowedPolicy:new()
      allowed_policy.area_id = area.id
      allowed_policy.policy_id = config.firstlife_groups.policy_id
      allowed_policy.default_policy = true
      allowed_policy:save()
      unit = u
    end
    firstlife_mirror_group_users(unit)
  end

end


