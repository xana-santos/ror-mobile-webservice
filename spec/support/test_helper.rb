def json  
  @json ||= JSON.parse response.body
end

def json_headers
  {"Authorization" => "Bearer #{authorization}", "Content-Type" => "application/json"}
end

def authorization
  Authorization.first_or_create!.auth_token
end