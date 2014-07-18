-- Formats a value (or a key) for usage in the text representation of
-- hstore fields

function encode.pg_hstore_value(value)
  return '"' .. string.gsub(value, '([\\"])', "\\%1") .. '"'
end