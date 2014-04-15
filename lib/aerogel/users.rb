require 'omniauth'
require 'aerogel/core'
require 'aerogel/mailer'
require "aerogel/users/version"
require "aerogel/users/auth"
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
    Aerogel::Auth.load_middleware( app )
  end
end

