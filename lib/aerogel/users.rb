require 'omniauth'
require 'aerogel/core'
require "aerogel/users/version"
require "aerogel/users/omniauth-password"
require "aerogel/users/omniauth-failure_endpoint_ex"
require "aerogel/users/secure_password"

module Aerogel
  module Users
    # Your code goes here...
  end

  # Finally, register module's root folder
  register_path File.join( File.dirname(__FILE__), '..', '..' )

  on_load do |app|
    app.use OmniAuth::Builder do
      provider :password, model: User
      on_failure {|env| OmniAuth::FailureEndpointEx.new(env).redirect_to_failure }
    end
  end
end

