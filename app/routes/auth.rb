# Authentication system routes
route :get, :post, "/auth/:provider/callback" do
  flash[:debug] = "params.inspect: #{params.inspect}"

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
    auth_login( user, remember_me: !!params['remember_me'], provider: params[:provider], uid: request.env['omniauth.auth']['uid'] )
    logger.debug( "successfully authenticated: #{params.inspect} ")
    logger.debug( "user: #{user} ")
    auth_state result: :success
    flash[:notice] = t.aerogel.auth.welcome full_name: user.full_name
    auth_redirect_to_origin( params["on_success"] )
  else
    user = User.create_from_omniauth request.env['omniauth.auth']
    unless user.save
      flash[:error] = t.aerogel.auth.errors.create_from_omniauth errors: user.errors.inspect
      auth_redirect_to_origin( params["on_failure"] )
    end
    auth_login( user, remember_me: !!params['remember_me'], provider: params[:provider], uid: request.env['omniauth.auth']['uid'] )
    flash[:notice] = t.aerogel.auth.welcome_new_user full_name: user.full_name
    redirect "/user/edit"
  end
end

get "/auth/failure" do
  logger.debug( "failed to authenticate: #{params.inspect} ")
  flash[:debug] = "params.inspect: #{params.inspect}"
  auth_state params.merge(
    result: 'error',
    error: 'invalid_credentials',
    provider: params['provider'] || params['strategy']
  )
  auth_redirect_to_origin( params['on_failure'] )
end


# Retrieves auth_state
#
before do
  auth_state
end


