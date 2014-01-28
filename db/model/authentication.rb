class Authentication

  VALID_TYPES = [:password, :github]

  include Mongoid::Document
  include Aerogel::Db::SecurePassword


  embedded_in :user

  field :provider, type: Symbol
  field :uid, type: String
  field :email, type: String
  field :info, type: Hash
  use_secure_password

  # validations:
  validates :provider, allow_nil: false, inclusion: { in: VALID_TYPES }
  validates_presence_of :uid
  # validates :password, length: { minimum: 8 }, allow_nil: true

  # validates uniqueness of provider & uid among all users
  validate do |record|
    if User.elem_match( :authentications => { :provider => record.provider, :uid => record.uid, :_id.ne => record.id } ).count > 0
      record.errors.add :uid, 'must be unique'
    end
  end

  # Only validate password if provider is :password
  #
  def validate_password?
    provider == :password
  end

  # virtual attributes:

  # methods:


end # class Authentication


