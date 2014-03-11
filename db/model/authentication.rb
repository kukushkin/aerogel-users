class Authentication

  include Model
  include Aerogel::Db::SecurePassword

  VALID_PROVIDERS = Aerogel::Auth.providers.keys

  embedded_in :user

  field :provider, type: Symbol
  field :uid, type: String
  field :info, type: Hash

  # has one :email (through embedded user.emails), optional
  field :email_id, type: String

  field :password_reset_token, type: String

  use_secure_password


  # validations:
  validates_presence_of :provider, :uid
  validates :provider, inclusion: { in: VALID_PROVIDERS }
  # validates :password, length: { minimum: 8 }, allow_nil: true

  # validates uniqueness of provider & uid among all users
  validate do |record|
    if User.elem_match( :authentications => { :provider => record.provider, :uid => record.uid, :_id.ne => record.id } ).count > 0
      record.errors.add :uid, :unique
    end
  end

  # Only validate password if provider is :password
  #
  def validate_password?
    provider == :password
  end

  # virtual attributes:

  # Returns email associated with this Authentication
  #
  def email
    user.emails.where( email: self.email_id ).first
  end


  # methods:


end # class Authentication


