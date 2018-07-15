local controlled_id = param.get("controlled_id")

local agent = Agent:by_pk(controlled_id, app.session.member_id)

if not agent then
  print("A")
  return false
end

if agent.accepted ~= nil then
  print("B")
  return false
end

if param.get("rejected") then
  print("C")
  agent.accepted = false
elseif param.get("accepted") then
  print("D")
  agent.accepted = true
else
  print("E")
  return false
end
print("F")
agent:save()
