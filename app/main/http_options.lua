-- TODO workaround, needs to be resolved in WebMCP's request.handler
if not request._route then
  return
end

if request.get_module() == "oauth2" and 
  (request.get_view() == "session" or request.get_view() == "validate")
then 
  local origin = request.get_header("Origin")
  if origin then
    request.add_header("Access-Control-Allow-Origin", origin)
  end
  request.add_header("Access-Control-Allow-Credentials", "true")
  request.add_header("Access-Control-Max-Age", "0")
else
  request.add_header("Access-Control-Allow-Origin", "*")
end
    
request.add_header("Access-Control-Allow-Headers", "Authorization")
