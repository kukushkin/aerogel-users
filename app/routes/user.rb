
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

  get '/logout' do
    auth_logout
    flash.now[:notice] = "Logged out"
    pass
  end

  #
  # Account management routes
  #
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
    @user_request_account_activation_form = UserRequestAccountActivationForm.new
    pass
  end

  post '/request_account_activation' do
    @user_request_account_activation_form = UserRequestAccountActivationForm.new(
      params[:user_request_account_activation_form]
    )
    pass unless @user_request_account_activation_form.valid?
    user = @user_request_account_activation_form.user
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
    @user_request_email_confirmation_form = UserRequestEmailConfirmationForm.new
    pass
  end

  post '/request_email_confirmation' do
    @user_request_email_confirmation_form = UserRequestEmailConfirmationForm.new(
      params[:user_request_email_confirmation_form]
    )
    pass unless @user_request_email_confirmation_form.valid?
    user_email = @user_request_email_confirmation_form.user_email
    user_email.user.request_email_confirmation! @user_request_email_confirmation_form.email
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

  get '/request_password_reset' do
    @user_request_password_reset_form = UserRequestPasswordResetForm.new
    pass
  end

  post '/request_password_reset' do
    @user_request_password_reset_form = UserRequestPasswordResetForm.new(
      params[:user_request_password_reset_form]
    )
    pass unless @user_request_password_reset_form.valid?
    user = @user_request_password_reset_form.user
    authentication = user.request_password_reset! @user_request_password_reset_form.email
    email 'user/password_reset', authentication
    view 'user/request_password_reset_success'
  end

  get '/reset_password' do
    @user_reset_password_form = UserResetPasswordForm.new(
      email: params['email'],
      password_reset_token: params['token']
    )
    pass
  end

  post '/reset_password' do
    @user_reset_password_form = UserResetPasswordForm.new(
      params[:user_reset_password_form]
    )
    pass unless @user_reset_password_form.valid?
    begin
      user = User.reset_password!(
        @user_reset_password_form.email,
        @user_reset_password_form.password_reset_token,
        @user_reset_password_form.password,
        @user_reset_password_form.password_confirmation
      )
      view 'user/reset_password_success'
    rescue StandardError => e
      flash.now[:error] = e.to_s
      pass
    end
  end

  #
  # Edit user profile
  #
  get '/edit' do
    @user = current_user
    pass
  end

  post '/edit' do
    @user = User.find( params[:id] )
    unless @user
      flash[:error] = "Failed to locate user profile"
      pass
    end
    unless @user.id == current_user.id
      flash[:error] = "Access denied"
      redirect '/user'
    end
    unless @user.update_attributes params[:user]
      flash[:error] = "Failed to update user profile"
      pass
    end
    flash[:notice] = "User details saved"
    redirect '/user'
  end

  #
  # Common User controller routes
  #
  route :get, :post, ['', '/:action'] do
    action = params[:action] || 'index'
    view "user/#{action}"
  end


end # namespace '/user'

