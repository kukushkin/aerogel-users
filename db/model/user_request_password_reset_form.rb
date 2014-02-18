class UserRequestPasswordResetForm

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
    authentication = user.authentications.where( provider: :password, uid: record.email ).first
    unless authentication
      record.errors.add :email, 'does not allow log in using password'
      return
    end
  end

  # Returns User object, corresponding to this email address
  #
  def user
    User.where( 'emails.email' => email ).first
  end

  # Returns UserEmail object, corresponding to this email address
  #
  def authentication
    user.authentications.where( provider: :password, uid: email ).first
  end


end # class UserRequestPasswordResetForm
