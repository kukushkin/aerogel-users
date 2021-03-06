require 'securerandom'

class User

  include Model
  include Model::Timestamps

  field :full_name, type: String
  field :roles, type: Array
  field :authenticated_at, type: Time

  validates_presence_of :full_name

  embeds_many :authentications
  accepts_nested_attributes_for :authentications

  embeds_many :emails, class_name: "UserEmail"
  accepts_nested_attributes_for :emails



  # validations:
  validate do |record|
    # validate roles
    if record.roles_changed?
      unless Role.slugs.contains? record.roles
        record.errors.add :roles, :invalid_roles
      end
    end
  end

  # accessors:
  def roles=( value )
    if value.is_a? Array
      self[:roles] = value.map(&:to_sym)
    elsif value.is_a? String
      self[:roles] = value.split(",").map{|v| v.strip.to_sym}
    else
      raise ArgumentError.new "Invalid value of class #{value.class} passed to roles= setter"
    end
  end

  # methods:

  # Find user authenticated by provider and params.
  #
  # For Password strategy, corresponding Authentication is found
  # by params[:uid] and params[:password].
  #
  # For other strategies (github, facebook, twitter etc) only params[:uid] is used
  #
  def self.authenticate( provider, params )
    logger.warn( "User.authenticate: #{provider} #{params}")
    user = find_by_authentication( provider, params['uid'] )
    return nil unless user
    if provider == :password
      a = user.authentications.where( provider: provider, uid: params['uid'] ).first
      if a.password_is? params['password']
        user
      else
        nil
      end
    else
      user
      # self.elem_match( :authentications => { provider: provider, uid: params['uid'] } ).first
    end
  end

  # Finds user by authentication (provider & uid).
  #
  def self.find_by_authentication( provider, uid )
    self.elem_match( :authentications => { provider: provider, uid: uid } ).first
  end


  # Creates a User from another +object+.
  # +object+ may be a UserRegistrationForm.
  #
  def self.create_from( object )
    raise "Cannot create User from #{object.class}" unless object.is_a? UserRegistrationForm

    self.new(
      full_name: object.full_name,
      roles: [:user],
      emails: [{
        email: object.email,
        confirmed: false
      }],
      authentications: [{
        provider: :password,
        uid: object.email,
        email_id: object.email,
        password: object.password,
        password_confirmation: object.password_confirmation
      }]
    )
  end

  # Creates a User from omniauth AuthHash
  #
  def self.create_from_omniauth( omniauth_hash )
    raise "Cannot create User from #{omniauth_hash.class}" unless omniauth_hash.is_a? OmniAuth::AuthHash

    info = omniauth_hash['info'].to_hash
    emails = []
    emails << { email: info['email'], confirmed: false } if info['email']
    self.new(
      full_name: info['name'],
      roles: [:user],
      emails: emails,
      authentications: [{
        provider: omniauth_hash.provider.to_sym,
        uid: omniauth_hash.uid,
        info: info
      }]
    )
  end

  # Generates secure confirmation token using +seed+ for random
  #
  def self.generate_confirmation_token()
    SecureRandom::hex
  end

  # Requests activation of newly registered user:
  # requests confirmation of email used in password authentication.
  #
  def request_activation!
    object = emails.first
    request_email_confirmation!( object.email )
  end

  # Activates account: confirms user email used in password authentication.
  # Returns corresponding User object on success.
  # Raises error if confirmation fails.
  #
  def self.activate!( email, token )
    confirm_email! email, token
  end

  # Returns +true+ if user is activated and password authentication uses +email+.
  #
  def activated?( email )
    a = authentications.where( uid: email ).first
    return false unless a
    a.email.email == email && a.email.confirmed
  end


  # Requests confirmation of given email address.
  # Returns corresponding UserEmail object with newly generated confirmation_token
  #
  def request_email_confirmation!( email )
    object = emails.where( email: email ).first
    raise "Email '#{email}' does not belong to user" unless object
    object.confirmation_token = User.generate_confirmation_token
    object.save!
    object
  end

  # Confirms user email using previously issued token.
  # Returns corresponding User object on success.
  # Raises error if confirmation fails.
  #
  def self.confirm_email!( email, token )
    user = self.where( 'emails.email' => email ).first
    raise NotFoundError.new :user_not_found unless user
    user_email = user.emails.where( email: email ).first
    raise NotFoundError.new :user_email_not_found unless user_email
    raise InvalidOperationError.new :email_already_confirmed if user_email.confirmed?
    raise InvalidOperationError.new :invalid_confirmation_token if !token.nil? && user_email.confirmation_token != token
    user_email.confirmed = true
    user_email.save!
    user
  end

  # Requests password reset of authentication with given email address.
  # Returns corresponding Authentication object with newly generated password_reset_token
  #
  def request_password_reset!( email )
    object = authentications.where( provider: :password, uid: email ).first
    raise NotFoundError.new "Failed to find password authentication for user with email:'#{email}'" unless object
    object.password_reset_token = User.generate_confirmation_token
    object.save!
    object
  end

  # Resets user password using previously issued token.
  # Returns corresponding User object on success.
  # Raises error if password reset fails.
  #
  def self.reset_password!( email, token, password, password_confirmation )
    user = self.where( 'emails.email' => email ).first
    raise NotFoundError.new "Failed to find user by email" unless user
    authentication = user.authentications.where( provider: :password, uid: email ).first
    raise NotFoundError.new "Failed to find password authentication for user with email:'#{email}'" unless authentication
    raise "Password reset is not requested" if authentication.password_reset_token.nil?
    raise "Password reset token is invalid" if authentication.password_reset_token != token
    authentication.password = password
    authentication.password_confirmation = password_confirmation
    authentication.password_reset_token = nil
    authentication.save!
    user
  end


  # Updates authenticated_at, does not change other timestamps.
  # Resets password_reset_token if :provider is 'password'
  # Returns self.
  #
  def authenticated!( opts = {} )
    self.timeless.update_attributes authenticated_at: Time.now
    if opts[:provider] == 'password'
      authentication = self.authentications.where( provider: :password, uid: opts[:uid] ).first
      unless authentication.password_reset_token.nil?
        authentication.update_attributes password_reset_token: nil
      end
    end
    self
  end

end # class User

