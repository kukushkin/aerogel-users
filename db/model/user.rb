require 'securerandom'

class User

  include Model

  field :full_name, type: String

  validates_presence_of :full_name

  embeds_many :authentications
  accepts_nested_attributes_for :authentications

  embeds_many :emails, class_name: "UserEmail"
  accepts_nested_attributes_for :emails


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

  # Generates secure confirmation token using +seed+ for random
  #
  def self.generate_confirmation_token()
    SecureRandom::hex
  end

  # Requests confirmation of given email address.
  # Returns corresponding UserEmail object with newly generated confirmation_token
  #
  def request_email_confirmation( email )
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
    raise NotFoundError.new "Failed to find user by email" unless user
    user_email = user.emails.where( email: email ).first
    raise NotFoundError.new "Failed to find email object" unless user_email
    raise "Email is already confirmed" if user_email.confirmed?
    raise "Confirmation token is invalid" if user_email.confirmation_token != token
    user_email.confirmed = true
    user_email.save!
    user
  end

end # class User

