local controlled_id = param.get("controlled_id")

local agent = Agent:by_pk(controlled_id, app.session.member_id)

if not agent then
  return false
end

if agent.accepted ~= nil then
  return false
end

if param.get("rejected") then
  agent.accepted = false
elseif param.get("accepted") then
  agent.accepted = true
else
  return false
end

agent:save()
