
def link_to_social_login( provider_key, text = nil, on_success = nil )
  provider = Aerogel::Auth::PROVIDERS[provider_key] || {}
  text ||= provider[:name]
  origin = on_success || params['on_success']
  query_string = origin ? "?origin=#{origin}" : ''
  link_to "/auth/#{provider_key}#{query_string}", text.to_s, title: "log in using #{provider[:name]}"
end