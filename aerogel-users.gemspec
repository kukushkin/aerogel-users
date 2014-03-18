# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aerogel/users/version'

Gem::Specification.new do |spec|
  spec.name          = "aerogel-users"
  spec.version       = Aerogel::Users::VERSION
  spec.authors       = ["Alex Kukushkin"]
  spec.email         = ["alex@kukushk.in"]
  spec.description   = %q{User management for aerogel}
  spec.summary       = %q{User management for aerogel}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "aerogel-core", ">= 1.2.0"
  spec.add_dependency "aerogel-font_awesome"
  spec.add_dependency "omniauth"
  spec.add_dependency "bcrypt"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
