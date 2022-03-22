function _G.sync_token()
  local request = [[
    {
      "query": "query balanceNotificationMany($tokenSymbol: String) {
        balanceNotificationMany(filter: { token_symbol: $tokenSymbol }) {
            _id
            account_pk
            name
            token_symbol
            amount
            contractAddress
            owner
        }
      }",
      "variables": {
        "tokenSymbol": "]] .. config.token.token_name .. [["
      }
    }
  ]]

  local output, err, status = extos.pfilter(request, "curl", "--insecure", "-X", "POST", "-H", "Content-Type: application/json", "-H", "X-REQUEST-TYPE: GraphQL", "-d", "@-", config.token.graphql_url)

  local data = json.import(output)

  local privileged_member_ids = {}
  for i, entry in ipairs(data.data.balanceNotificationMany) do
    local member = Member:new_selector()
      :join("member_profile", nil, "member_profile.member_id = member.id")
      :add_where{ "member_profile.profile->>'" .. config.token.key_profile_field .."' = ?", entry.account_pk }
      :optional_object_mode()
      :exec()
    if member then
      privileged_member_ids[member.id] = true
      local privilege = Privilege:new_selector()
        :add_where{ "unit_id = ?", config.token.unit_id }
        :add_where{ "member_id = ?", member.id }
        :optional_object_mode()
        :exec()
      if not privilege then
        privilege = Privilege:new()
        privilege.unit_id = config.token.unit_id
        privilege.member_id = member.id
      end
      privilege.initiative_right = true
      privilege.voting_right = true
      privilege.weight = entry.amount
      privilege:save()
    end
  end

  local privileges = Privilege:new_selector()
    :add_where{ "unit_id = ?", config.token.unit_id }
    :exec()

  for i, privilege in ipairs(privileges) do
    if not privileged_member_ids[privilege.member_id] then
      privilege:destroy()
    end
  end


end

