# Redirects after authentication process to the most appropriate origin URL.
#
# Possible origins (URLs to redirect to) are tried in following order:
#   explicit_origin
#   request.env['omniauth.origin']
#   request.params['origin']
#   default_origin
#
def auth_redirect_to_origin( explicit_origin, default_origin = "/" )
  url = explicit_origin || request.env['omniauth.origin'] || request.params['origin'] || default_origin
  redirect url
end

def auth_login( user, remember_me = false )
  session[:user_id] = user.id
  session[:remember_me] = remember_me
  user.touch_authenticated_at!
  auth_keepalive_session
end

def auth_logout
  session[:user_id] = nil
  session[:remember_me] = nil
  session.options[:expire_after] = nil
end

def auth_keepalive_session
  session.options[:expire_after] = 2592000 if session[:remember_me]
end

# Returns User object of the current authenticated user or +nil+.
#
def current_user
  auth_keepalive_session
  @current_user ||= ( session[:user_id] ? User.find( session[:user_id] ) : nil )
end

# Returns +true+ if user is authenticated, +false+ otherwise.
#
def current_user?
  !current_user.nil?
end

# Gets or sets auth state.
# 'auth state' is a one-time used Hash used to store auth system data between requests.
#
def auth_state( value = nil )
  if value
    @auth_state = value
    session[:auth_state] = value.to_json
    return @auth_state
  end
  unless @auth_state
    @auth_state = session[:auth_state].nil? ? {} : JSON.parse( session[:auth_state] )
    session[:auth_state] = nil
  end
  @auth_state
end
