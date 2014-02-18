class UserRequestAccountActivationForm

  include Model::NonPersistent

  field :email, type: String

  validates_presence_of :email
  validates_format_of :email, with: /@/, message: 'invalid email'

  # validates uniqueness of provider & uid (email) among all users
  validate do |record|
    user = User.where( 'emails.email' => record.email ).first
    unless user
      record.errors.add :email, 'is not registered for any user'
      return
    end
    if user.activated?( record.email )
      record.errors.add :base, 'Your account is already active'
      return
    end
  end

  # Returns UserEmail object, corresponding to this email address
  #
  def user
    user = User.where( 'emails.email' => email ).first
  end


end # class UserRequestAccountActivationForm
