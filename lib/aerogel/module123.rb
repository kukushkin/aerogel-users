require 'aerogel'
require "aerogel/module123/version"

module Aerogel
  module Module123
    # Your code goes here...
  end

  # Finally, register module's root folder
  register_path File.join( File.dirname(__FILE__), '..', '..' )
end

