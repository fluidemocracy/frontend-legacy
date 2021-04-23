slot.set_layout(nil, "application/json")

local r = json.array()

local system_applications = SystemApplication:get_all()

local base_url = request.get_absolute_baseurl()

if string.sub(base_url, -1, -1) == "/" then
  base_url = string.sub(base_url, 1, -2)
end

r[#r+1] = json.object{
  type = "system",
  name = "LiquidFeedback",
  base_url = base_url,
  manifest_url = request.get_absolute_baseurl() .. "api/1/info",
  cert_common_name = config.oauth2.cert_common_name
}

for i, system_application in ipairs(system_applications) do
  r[#r+1] = json.object{
    type = "system",
    name = system_application.name,
    base_url = system_application.base_url,
    manifest_url = system_application.manifest_url,
    cert_common_name = system_application.cert_common_name
  }
end

if app.access_token then

  local member_applications = MemberApplication:by_member_id_with_domain(app.access_token.member_id)

  for i, member_application in ipairs(member_applications) do
    r[#r+1] = json.object{
      type = "dynamic",
      name = "https://" .. member_application.domain .. "/",
      base_url = "https://" .. member_application.domain .. "/",
      manifest_url = "https://" .. member_application.domain .. "/" .. config.oauth2.manifest_magic
    }
  end

end

slot.put_into("data", json.export(json.object{ result = r }))
