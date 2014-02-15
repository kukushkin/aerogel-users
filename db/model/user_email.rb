class UserEmail

  include Model

  field :email, type: String
  field :confirmed, type: Boolean
  field :confirmation_token, type: String

  embedded_in :user

  # validates uniqueness of email among all users
  validate do |record|
    if User.elem_match( :emails => { :email => record.email, :_id.ne => record.id } ).count > 0
      record.errors.add :email, 'must be unique'
    end
  end

  # Returns Authentication associated with email, if any
  #
  # def authentication
  #  user.authentications.where( email_id: self.id )
  # end

end # class UserEmail