class User

  include Mongoid::Document

  embeds_many :authentications

  field :name, type: String

  accepts_nested_attributes_for :authentications

  validates_presence_of :name

  # methods:

  # Find user authenticated by provider and params.
  #
  # For Password strategy, corresponding Authentication is found
  # by params[:uid] and params[:password].
  #
  # For other strategies (github, facebook, twitter etc) params[:uid] is used
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


end # class User

