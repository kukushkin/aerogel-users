
# Returns A HREF link to a login using given provider.
#
def link_to_social_login( provider_key, text = nil, on_success = nil )
  provider = Aerogel::Auth.providers[provider_key] || {}
  text ||= provider[:name]
  link_to url_to_social_login( provider_key, on_success ), text.to_s, title: "log in using #{provider[:name]}"
end


# Returns URL to a login using given provider.
#
def url_to_social_login( provider_key, on_success = nil )
  provider = Aerogel::Auth.providers[provider_key] || {}
  origin = on_success || params['on_success']
  query_string = origin ? "?origin=#{origin}" : ''
  "/auth/#{provider_key}#{query_string}"
end