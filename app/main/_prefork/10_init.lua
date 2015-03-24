if not config.fork then
  config.fork = {}
end

if not config.fork.pre then
  config.fork.pre = 4
end

if not config.fork.max then
  config.fork.max = 8
end

if not config.fork.delay then
  config.fork.delay = 1
end

if not config.port then
  config.port = 8080
end

if config.localhost == nil then
  config.localhost = true
end

listen{
 { proto = "tcp4", port = config.port, localhost = true },
 { proto = "interval", delay = 5, handler = function() 
    Event:send_pending_notifications()
 end },
 pre_fork = config.fork.pre,
 max_fork = config.fork.max,
 fork_delay = config.fork.delay
}

execute.inner()

