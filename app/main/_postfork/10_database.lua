-- open and set default database handle
_G.db = assert(mondelefant.connect(config.database))

function mondelefant.class_prototype:get_db_conn() return db end

-- enable output of SQL commands in trace system
function db:sql_tracer(command)
  return function(error_info)
    local error_info = error_info or {}
    trace.sql{ command = command, error_position = error_info.position }
  end
end

execute.inner()

-- close the database
db:close()
