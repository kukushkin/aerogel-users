# Authentication system routes
route :get, :post, "/auth/:provider/callback" do
  user = User.find_by_authentication( params[:provider].to_sym, request.env['omniauth.auth']['uid'] )
  # registered user
  auth_login( user, !!params['remember_me'] ) if user

  username = user ? user.full_name : 'unknown-user'
  logger.debug( "successfully authenticated: #{params.inspect} ")
  logger.debug( "user: #{user} ")
  flash.now[:notice] = "Successfully authenticated: #{params.inspect}, user: #{username}"
  auth_redirect_to_origin( params["on_success"] )
end

get "/auth/failure" do
  logger.debug( "failed to authenticate: #{params.inspect} ")
  flash.now[:error] = "failed to authenticate: #{params.inspect}"
  auth_redirect_to_origin( params['on_failure'] )
end




