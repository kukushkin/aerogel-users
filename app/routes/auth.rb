# Authentication system routes
route :get, :post, "/auth/:provider/callback" do
  user = User.find_by_authentication( params[:provider].to_sym, request.env['omniauth.auth']['uid'] )
  if params[:provider] == 'password' && !user.activated?( request.env['omniauth.auth']['uid'] )
    auth_state params.merge(
      result: 'error',
      error: 'account_not_activated'
    )
    auth_redirect_to_origin( params['on_failure'] )
    halt
  end

  if user
    # registered user
    auth_login( user, !!params['remember_me'] )
    logger.debug( "successfully authenticated: #{params.inspect} ")
    logger.debug( "user: #{user} ")
    auth_state result: :success
    flash[:notice] = "Welcome, #{user.full_name}!"
    auth_redirect_to_origin( params["on_success"] )
  else
    user = User.create_from_omniauth request.env['omniauth.auth']
    unless user.save
      flash[:error] = "Failed to register new User: #{user.errors.inspect}"
      auth_redirect_to_origin( params["on_failure"] )
    end
    auth_login( user, !!params['remember_me'] )
    flash[:notice] = "Welcome, #{user.full_name}! Please review and update your details if necessary."
    redirect "/user/edit"
  end
end

get "/auth/failure" do
  logger.debug( "failed to authenticate: #{params.inspect} ")
  auth_state params.merge(
    result: 'error',
    error: 'invalid_credentials'
  )
  auth_redirect_to_origin( params['on_failure'] )
end


# Retrieves auth_state
#
before do
  auth_state
end


