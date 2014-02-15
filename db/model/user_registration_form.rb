class UserRegistrationForm

  include Model::NonPersistent

  field :full_name, type: String
  field :email, type: String
  field :password, type: String

  validates_presence_of :full_name, :email, :password, :password_confirmation
  validates_confirmation_of :password
  validates_format_of :email, with: /@/, message: 'invalid email'

  # validates uniqueness of provider & uid (email) among all users
  validate do |record|
    if User.elem_match( :authentications => { :provider => :password, :uid => record.email } ).count > 0
      record.errors.add :email, 'is already in use'
    elsif User.elem_match( :emails => { :email => record.email } ).count > 0
      record.errors.add :email, 'is already in use'
    end
  end


end # class UserRegistrationForm
