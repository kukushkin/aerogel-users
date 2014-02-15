namespace '/user' do

  # User management routes
  get '/logout' do
    auth_logout
    flash.now[:notice] = "Logged out"
    pass
  end

  get '/register' do
    @user_registration_form = UserRegistrationForm.new
    pass
  end

  post '/register' do
    @user_registration_form = UserRegistrationForm.new( params[:user_registration_form] )
    pass unless @user_registration_form.valid?
    user = User.create_from @user_registration_form
    unless user.save
      flash[:error] = "Failed to save User: #{user.errors.inspect}"
      pass
    end
    user_email = user.request_email_confirmation( @user_registration_form.email )
    email 'user/email_confirmation', user_email
    view "user/register_success"
  end

  get '/confirm_email' do
    begin
      user = User.confirm_email!( params['email'], params['token'] )
      pass
    rescue StandardError => e
      flash.now[:error] = e.to_s
      view 'user/confirm_email_failure'
    end
  end

  route :get, :post, ['', '/:action'] do
    action = params[:action] || 'index'
    view "user/#{action}"
  end

  before do
    if request.path_info == '/user' && current_user.nil?
      flash[:error] = "Access denied"
      redirect "/"
    end
  end

end # namespace '/user'

