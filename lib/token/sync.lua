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

  local privileges = Privilege:new_selector()
    :add_where{ "unit_id = ?", config.token.unit_id }
    :exec()

  for i, privilege in ipairs(privileges) do
    privilege:destroy()
  end

  for i, entry in ipairs(data.data.balanceNotificationMany) do
    print(entry.account_pk, entry.amount)
    local member = Member:new_selector()
      :join("member_profile", nil, "member_profile.member_id = member.id")
      :add_where{ "member_profile.profile->>'" .. config.token.key_profile_field .."' = ?", entry.account_pk }
      :optional_object_mode()
      :exec()
    print(member.name)
    if member then
      local privilege = Privilege:new()
      privilege.unit_id = config.token.unit_id
      privilege.member_id = member.id
      privilege.initiative_right = true
      privilege.voting_right = true
      privilege.weight = entry.amount
      privilege:save()
    end
  end

end