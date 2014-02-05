# Authentication system routes
route :get, :post, "/auth/:provider/callback" do
  user = User.find_by_authentication( params[:provider].to_sym, request.env['omniauth.auth']['uid'] )
  # registered user
  auth_login( user, !!params['remember_me'] ) if user

  username = user ? user.name : 'unknown-user'
  logger.debug( "successfully authenticated: #{params.inspect} ")
  logger.debug( "user: #{user} ")
  flash[:notice] = "Successfully authenticated: #{params.inspect}, user: #{username}"
  auth_redirect_to_origin( params["on_success"] )
end

get "/auth/failure" do
  logger.debug( "failed to authenticate: #{params.inspect} ")
  flash[:error] = "failed to authenticate: #{params.inspect}"
  auth_redirect_to_origin( params['on_failure'] )
end

# roles:
# registered user: /user, /user/edit
# admin: /admin

# User management routes
get '/user/logout' do
  auth_logout
  flash.now[:notice] = "Logged out"
  pass
end

get '/user/register' do
  @user_registration_form = UserRegistrationForm.new
  pass
end

post '/user/register' do
  @user_registration_form = UserRegistrationForm.new( params[:user_registration_form] )
  logger.debug @user_registration_form
  pass unless @user_registration_form.valid?
  user = @user_registration_form.to_user
  unless user.valid?
    logger.error user.errors.messages
    pass
  end
  logger.info "On the way to successful registration..."
  logger.info user
  pass unless user.save
  erb :"user/register-ok.html"
end

route :get, :post, ['/user', '/user/:action'] do
  action = params[:action] || 'index'
  erb :"user/#{action}.html"
end

before do
  if request.path_info == '/user' && current_user.nil?
    flash[:error] = "Access denied"
    redirect "/"
  end
end


