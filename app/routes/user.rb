namespace '/user' do

  get '/login' do
    @error_message = nil
    params['on_success'] ||= auth_state['on_success'] || '/'
    params['on_failure'] ||= auth_state['on_failure'] || '/user/login'
    params['email'] ||= auth_state['email']
    if auth_state['result'] == 'error'
      if auth_state['error'] == 'invalid_credentials'
        @error_message = "Invalid email or password"
      elsif auth_state['error'] == 'account_not_activated'
        @error_message = "Your account is not activated yet. "+
        "Request <a href='/user/request_account_activation'>account activation</a> again."
      else
        @error_message = "Failed to log in: #{auth_state['error']}"
      end
    end
    pass
  end

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
    user.request_activation!
    email 'user/account_activation', user
    view "user/register_success"
  end

  get '/request_account_activation' do
    @user_account_activation_form = UserAccountActivationForm.new( params[:user_account_activation_form] )
    pass
  end

  post '/request_account_activation' do
    @user_account_activation_form = UserAccountActivationForm.new( params[:user_account_activation_form] )
    pass unless @user_account_activation_form.valid?
    user = @user_account_activation_form.user
    user.request_activation!
    email 'user/account_activation', user
    view 'user/request_account_activation_success'
  end


  get '/activate_account' do
    begin
      @user = User.activate!( params['email'], params['token'] )
      pass
    rescue StandardError => e
      flash.now[:error] = e.to_s
      view 'user/activate_account_failure'
    end
  end

  get '/request_email_confirmation' do
    @user_email_confirmation_form = UserEmailConfirmationForm.new( params[:user_email_confirmation_form] )
    pass
  end

  post '/request_email_confirmation' do
    @user_email_confirmation_form = UserEmailConfirmationForm.new( params[:user_email_confirmation_form] )
    pass unless @user_email_confirmation_form.valid?
    user_email = @user_email_confirmation_form.user_email
    user_email.user.request_email_confirmation! @user_email_confirmation_form.email
    email 'user/email_confirmation', user_email
    view 'user/request_email_confirmation_success'
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

