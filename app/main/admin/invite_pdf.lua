local id = param.get_id()

local member = Member:by_id(id)


local luatex = require("luatex")
luatex.temp_dir = WEBMCP_BASE_PATH .. "tmp"

local tex = luatex.new_document()

local template = config.invitation.template

if type(template) == "function" then
  template = template(member)
else
  template = template:gsub("#{invite_code}", member.invite_code)
  template = template:gsub("#{url}", request.get_absolute_baseurl())
end

tex(template)

local pdf = tex:get_pdf()

slot.set_layout(nil, "application/pdf")
slot.put_into("data", pdf)
