-- Encodes a Lua table as PostgreSQL hstore text input
-- TODO This should be implemented in the SQL abstraction layer

function encode.pg_hstore(hstore_values)

  local entries = {}
  
  for key, val in pairs(hstore_values) do
    local escaped_key = encode.pg_hstore_value(key)
    local escaped_val = encode.pg_hstore_value(val)
    entries[#entries+1] = escaped_key .. "=>" .. escaped_val
  end

  return table.concat(entries, ", ")

end
