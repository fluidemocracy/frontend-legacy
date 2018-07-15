local oddmap = {
  [0] = 1, 0, 5, 7, 9, 13, 15, 17, 19, 21,
  2, 4, 18, 20, 11, 3, 6, 8, 12, 14, 16,
  10, 22, 25, 24, 23
}

local monthtable = {
  "A", "B", "C", "D", "E", "H", "L", "M", "P", "R", "S", "T"
}

local function removeaccent(str)
  local gsub = string.gsub
  str = gsub(str, "\195\129", "A")
  str = gsub(str, "\195\128", "A")
  str = gsub(str, "\195\161", "a")
  str = gsub(str, "\195\160", "a")
  str = gsub(str, "\195\137", "E")
  str = gsub(str, "\195\136", "E")
  str = gsub(str, "\195\169", "e")
  str = gsub(str, "\195\168", "e")
  str = gsub(str, "\195\141", "I")
  str = gsub(str, "\195\140", "I")
  str = gsub(str, "\195\173", "i")
  str = gsub(str, "\195\172", "i")
  str = gsub(str, "\195\147", "O")
  str = gsub(str, "\195\146", "O")
  str = gsub(str, "\195\179", "o")
  str = gsub(str, "\195\178", "o")
  str = gsub(str, "\195\154", "U")
  str = gsub(str, "\195\153", "U")
  str = gsub(str, "\195\186", "u")
  str = gsub(str, "\195\185", "u")
  return str
end

local function normalize_name(str)
  local gsub = string.gsub
  str = removeaccent(str)
  str = gsub(str, " ", "")
  str = gsub(str, "-", "")
  str = gsub(str, "'", "")
  str = gsub(str, "\226\128\146", "")
  str = gsub(str, "\226\128\147", "")
  str = gsub(str, "\226\128\148", "")
  if string.find(str, "^[A-Za-z]+$") then
    return string.upper(str)
  else
    return nil
  end
end

local function remove_consonants(str)
  return (string.gsub(str, "[BCDFGHJKLMNPQRSTVWXYZ]", ""))
end

local function remove_vowels(str)
  return (string.gsub(str, "[AEIOU]", ""))
end

local function numberize(str)
  local gsub = string.gsub
  str = gsub(str, "L", "0")
  str = gsub(str, "M", "1")
  str = gsub(str, "N", "2")
  str = gsub(str, "P", "3")
  str = gsub(str, "Q", "4")
  str = gsub(str, "R", "5")
  str = gsub(str, "S", "6")
  str = gsub(str, "T", "7")
  str = gsub(str, "U", "8")
  str = gsub(str, "V", "9")
  return str
end

return function(code, data)
  local sub = string.sub
  local byte = string.byte
  local byte0 = byte("0")
  local byteA = byte("A")
  local function byteat(str, pos)
    return (byte(sub(str, pos, pos)))
  end
  if #code ~= 16 then
    return false, "Invalid length"
  end
  local sum = 0
  for i = 1, 15, 2 do
    local b = byteat(code, i)
    local b0 = b - byte0
    if b0 >= 0 and b0 <= 9 then
      sum = sum + oddmap[b0]
    else
      local bA = b - byteA
      if bA >= 0 and bA <= 25 then
        sum = sum + oddmap[bA]
      else
        return false, "Invalid character"
      end
    end
  end
  for i = 2, 14, 2 do
    local b = byteat(code, i)
    local b0 = b - byte0
    if b0 >= 0 and b0 <= 9 then
      sum = sum + b0
    else
      local bA = b - byteA
      if bA >= 0 and bA <= 25 then
        sum = sum + bA
      else
        return false, "Invalid character"
      end
    end
  end
  local check = byteat(code, 16)
  local checkA = check - byteA
  if checkA >= 0 and checkA <= 25 then
    if checkA ~= sum % 26 then
      return false, "Invalid checksum"
    end
  else
    local check0 = check - byte0
    if check0 >= 0 and check0 <= 9 then
      return false, "Checksum must not be numeric"
    else
      return false, "Invalid character"
    end
  end
  if data then
    if data.last_name then
      local name = normalize_name(data.last_name)
      if not name then
        return false, "Invalid last name"
      end
      local consonants = remove_vowels(name)
      local short = sub(consonants, 1, 3)
      if #short < 3 then
        local vowels = remove_consonants(name)
        short = short .. sub(vowels, 1, 3 - #short)
        while #short < 3 do
          short = short .. "X"
        end
      end
      if short ~= sub(code, 1, 3) then
        return false, "Last name not matching"
      end
    end
    if data.first_name then
      local name = normalize_name(data.first_name)
      if not name then
        return false, "Invalid first name"
      end
      local consonants = remove_vowels(name)
      local short
      if #consonants >= 4 then
        short = sub(consonants, 1, 1) .. sub(consonants, 3, 4)
      else
        short = consonants
        if #short < 3 then
          local vowels = remove_consonants(name)
          short = short .. sub(vowels, 1, 3 - #short)
          while #short < 3 do
            short = short .. "X"
          end
        end
      end
      if short ~= sub(code, 4, 6) then
        return false, "First name not matching"
      end
    end
    if data.year then
      local year = tostring(data.year % 100)
      if #year < 2 then
        year = "0" .. year
      end
      if year ~= numberize(sub(code, 7, 8)) then
        return false, "Year of birth not matching"
      end
    end
    if data.month then
      local monthchar = monthtable[data.month]
      if monthchar ~= sub(code, 9, 9) then
        return false, "Month of birth not matching"
      end
    end
    if data.day then
      local day = tostring(data.day)
      if #day < 2 then
        day = "0" .. day
      end
      local daycode = numberize(sub(code, 10, 11))
      if day ~= daycode and tostring(day + 40) ~= daycode then
        return false, "Day of birth not matching"
      end
    end
  end
  return true
end
