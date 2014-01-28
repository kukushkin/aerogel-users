require 'aerogel'
require "aerogel/users/version"

module Aerogel
  module Users
    # Your code goes here...
  end

  # Finally, register module's root folder
  register_path File.join( File.dirname(__FILE__), '..', '..' )
end

