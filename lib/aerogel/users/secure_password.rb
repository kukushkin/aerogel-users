require 'bcrypt'

module Aerogel
module Db
module SecurePassword

  include BCrypt

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def use_secure_password
      attr_reader :password

      field :password_digest, type: String

      validates_presence_of :password, on: :create, if: :validate_password?
      validates_confirmation_of :password, if: lambda { |r| r.password.present? }
      validates_presence_of :password_confirmation, if: lambda { |r| r.password.present? }

      if respond_to?(:attributes_protected_by_default)
        def self.attributes_protected_by_default #:nodoc:
          super + ['password_digest']
        end
      end

    end
  end


  def password=( new_password )
    unless new_password.blank?
      @password = new_password
      self.password_digest = Password.create( new_password )
    end
  end

  def password_confirmation=( new_password )
    @password_confirmation = new_password
  end

  def password_is?( unencrypted_password )
    Password.new(password_digest) == unencrypted_password
  end

  # If password should not be validated on each record,
  # override this method to make it conditional.
  #
  def validate_password?; true; end

end # module SecurePassword
end # module Db
end # module Aerogel