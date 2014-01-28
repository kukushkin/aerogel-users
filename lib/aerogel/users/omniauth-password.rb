require 'omniauth'

module OmniAuth
module Strategies
class Password
  include OmniAuth::Strategy

  PROVIDER_NAME = :password

  option :username_field, :email
  option :password_field, :password
  option :uid_field, :email
  if defined? User
    option :model, User
  else
    option :model, nil
  end
  option :authenticate_method, :authenticate

  option :on_authenticate, ->(params) {
    options.model.send( options.authenticate_method, PROVIDER_NAME, params )
  }


 # def request_phase
 #   form = OmniAuth::Form.new(:title => "User Info", :url => callback_path)
 #   [ options.username_field, options.password_field ].each do |field|
 #     form.text_field field.to_s.capitalize.gsub("_", " "), field.to_s
 #   end
 #   form.button "Sign In"
 #   form.to_response
 # end

  def callback_phase
    request.params['uid'] = uid
    request.env['omniauth.origin'] ||= request.params['origin']
    request.env['omniauth.params'] = request.params
    unless instance_exec( request.params, &options.on_authenticate )
      return fail!(:invalid_credentials)
    end
    super
  end

  uid do
    if options.uid_field.is_a? Proc
      options.uid_field.call( request.params )
    else
      request.params[options.uid_field.to_s]
    end
  end

  info do
    hash = {}
    [ options.username_field, options.password_field ].each do |field|
      hash[field] = request.params[field.to_s]
    end
    hash
  end


end # class Password
end # module Strategies
end # module OmniAuth
