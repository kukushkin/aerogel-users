
namespace '/user' do

  before do
    on_access_denied do |path|
      unless current_user?
        redirect "/user/login?on_success=#{path}"
      end
    end
  end

  get '/login' do
    @error_message = nil
    params['on_success'] ||= auth_state['on_success'] || '/'
    params['on_failure'] ||= auth_state['on_failure'] || '/user/login'
    params['email'] ||= auth_state['email']
    if auth_state['result'] == 'error'
      auth_state['provider'] ||= "i_think_its_password"
      # error messages are looked up in the following order:
      # aerogel.auth.<provider>.errors.<message>
      # aerogel.auth.errors.<message>
      # aerogel.auth.errors.unknown
      @error_message = t.aerogel.auth.send( auth_state['provider'].to_sym ).errors.send(
          auth_state['error'].to_sym,
          default: [ "aerogel.auth.errors.#{auth_state['error']}".to_sym, :'aerogel.auth.errors.unknown' ],
          provider: auth_state['provider'],
          message: auth_state['error']
      )
    end
    pass
  end

  get '/logout' do
    auth_logout
    flash.now[:notice] = t.aerogel.users.actions.logged_out
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
      flash[:error] = t.aerogel.db.errors.failed_to_save name: user.model_name.human,
        errors: user.errors.full_messages.join(', ')
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
      flash.now[:error] = t.error.messages.user_not_found
      pass
    end
    unless @user.id == current_user.id
      redirect '/user', error: "Access denied, user profile does not belong to you"
    end
    unless @user.update_attributes params[:user].except( :roles )
      flash.now[:error] = t.aerogel.db.errors.failed_to_save name: User.model_name.human,
        errors: @user.errors.full_messages.join(", ")
      pass
    end
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

