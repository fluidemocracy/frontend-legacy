function util.get_access_token()
    
  local access_token_header = request.get_header("Authorization")
  if access_token_header then
    access_token_header = string.match(access_token_header, "^Bearer ([^ ,]*)$")
  end

  local access_token_param = param.get("access_token")

  if access_token_header and access_token_param then
    return nil, "header_and_param"
  end
  
  return(access_token_header or access_token_param)

end
