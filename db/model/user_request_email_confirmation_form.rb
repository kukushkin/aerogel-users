class UserRequestEmailConfirmationForm

  include Model::NonPersistent

  field :email, type: String

  validates_presence_of :email
  validates_format_of :email, with: /@/, message: :invalid_format

  # validates uniqueness of provider & uid (email) among all users
  validate do |record|
    user = User.where( 'emails.email' => record.email ).first
    unless user
      record.errors.add :email, :not_registered
      return
    end
    user_email = user.emails.where( email: record.email ).first
    unless user_email
      record.errors.add :email, :invalid
      return
    end
    if user_email.confirmed
      record.errors.add :email, :already_confirmed
    end
  end

  # Returns User object, corresponding to this email address
  #
  def user
    User.where( 'emails.email' => email ).first
  end

  # Returns UserEmail object, corresponding to this email address
  #
  def user_email
    user.emails.where( email: email ).first
  end


end # class UserRequestEmailConfirmationForm
