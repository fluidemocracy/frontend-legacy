#!/usr/bin/env lua
local translations = loadcached(encode.file_path(WEBMCP_BASE_PATH, "locale", "translations.en.lua"))()

local additional_translations = {
["Abandon unit and area delegations for this issue"] = "Abandon city and subject area delegations for this issue";
["Abandon unit delegation"] = "Abandon city delegation";
["Abandon unit delegation for this area"] = "Abandon city delegation for this subject area";
["All units"] = "All cities";
["Apply unit delegation for this area (Currently: #{delegate_name} [#{scope}])"] = "Apply city delegation for this subject area (Currently: #{delegate_name} [#{scope}])";
["Apply unit or area delegation for this issue (Currently: #{delegate_name} [#{scope}])"] = "Apply city or subject area delegation for this issue (Currently: #{delegate_name} [#{scope}])";
["Create new unit"] = "Create new city";
["Current unit and area delegations need confirmation"] = "Current city and subject area delegations need confirmation";
["Delegate unit"] = "Delegate city";
["I want to delegate this organizational unit"] = "I want to delegate this city";
["I want to take a look at other organizational units"] = "I want to take a look at other cities";
["Minimum number of supporters relative to the number of active participants in the organizational unit."] = "Minimum number of supporters relative to the number of active participants in the city.";
["New organizational unit"] = "New organizational city";
["Organizational unit"] = "City";
["Organizational units"] = "Cities";
["Organizational units and subject areas"] = "Cities and subject areas";
["Parent unit"] = "Parent city";
["Select unit first"] = "Select city first";
["Set unit delegation"] = "Set city delegation";
["Trustee has no voting right in this unit"] = "Trustee has no voting right in this city";
["Unit"] = "City";
["Unit delegation"] = "City delegation";
["Unit list"] = "City list";
["You are not entitled to vote in this unit"] = "You are not entitled to vote in this city";
["You delegated this organizational unit"] = "You delegated this city";
["You delegated this unit"] = "You delegated this city";
["[event mail]      Unit: #{name}"] = "      City: #{name}";
["[introduction] organizational units"] = "To allow discussions and decisions by sub groups of participants (e.g. by the members of a subdivision of an organization), participants can be assigned to different units. Every organizational unit can have its own subject areas.";
["[introduction] vote delegation"] = "Delegations allow for a dynamic division of labor. A delegation is a proxy statement (voting power under a power of attorney), can be altered at any time, is not bound to directives and can be delegated onward. Delegations can be used for a whole organizational unit, for a subject area within an organizational unit, or for a specific issue. More specific delegations overrule more general delegations. Delegations are used in both the discourse (phase 1 to 3) and the voting phase. Any activity suspends existing delegations for the given activity.";
["change/revoke delegation of organizational unit"] = "change/revoke delegation of city";
["in my units"] = "in my cities";
["new unit created"] = "new city created";
["open the organizational unit, subject area or issue you like to delegate and follow the instruction on that page."] = "open the city, subject area or issue you want to delegate and follow the instruction on that page.";
["show all units"] = "Show all cities";
["unit"] = "city";
["unit updated"] = "city updated";
["update unit"] = "update city";
}

for k, v in pairs(additional_translations) do
  translations[k] = v
end
return translations;
