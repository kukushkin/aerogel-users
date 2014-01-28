class UserRegistrationForm < NonPersistent

  field :name, type: String
  field :email, type: String
  field :password, type: String

  validates_presence_of :name, :email, :password
  validates_confirmation_of :password

  # validates uniqueness of provider & uid (email) among all users
  validate do |record|
    if User.elem_match( :authentications => { :provider => :password, :uid => record.email } ).count > 0
      record.errors.add :email, 'is already in use'
    end
  end


  # Creates and returns User model from user registration form
  #
  def to_user
    user = User.new(
      name: name,
      authentications: [{
        provider: :password,
        uid: email,
        email: email,
        password: password,
        password_confirmation: password_confirmation
      }]
    )
    user
  end

end # class UserRegistrationForm
