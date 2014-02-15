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

def current_user
  auth_keepalive_session
  @current_user ||= ( session[:user_id] ? User.find( session[:user_id] ) : nil )
end
