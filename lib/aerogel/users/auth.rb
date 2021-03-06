module Aerogel
module Auth

  # known providers
#  PROVIDERS = {
#    password: { name: "Password", gem: nil },
#    github: { name: "GitHub", gem: 'omniauth-github' },
#    facebook: { name: "Facebook", gem: 'omniauth-facebook' },
#    twitter: { name: "Twitter", gem: 'omniauth-twitter' },
#    linkedin: { name: "LinkedIn", gem: 'omniauth-linkedin-oauth2' },
#    vkontakte: { name: "Vkontakte", gem: 'omniauth-vkontakte' }
#  }
#
  PROVIDERS = nil

  # Returns hash of registered omniauth providers.
  #
  def self.providers
    return @providers unless @providers.nil?
    @providers = Aerogel.config.auth.providers.to_hash
  end

  # Returns list of enabled omniauth providers as symbols.
  #
  # Example:
  #   Aerogel::Auth.enabled_providers # => [:password, :github, :twitter]
  #
  def self.enabled_providers
    return @enabled_providers unless @enabled_providers.nil?
    @enabled_providers = []
    providers.each do |provider, opts|
      # always enable :password
      next unless provider == :password || Aerogel.config.auth.send( :"#{provider}?" )
      @enabled_providers << provider
    end
    @enabled_providers
  end

  # Loads gems for enabled providers.
  #
  def self.load_provider_gems
    enabled_providers.each do |provider_key|
      gem_name = providers[provider_key][:gem_name]
      # puts "** requiring #{provider_key}: #{gem_name}"
      require gem_name if gem_name
    end
  end

  # Loads OmniAuth middleware with enabled providers.
  #
  def self.load_middleware( app )
    load_provider_gems
    app.use OmniAuth::Builder do
      # puts "** configuring OmniAuth"
      provider :password, model: User
      Aerogel::Auth.enabled_providers.each do |provider_key|
        next if provider_key == :password
        provider_config = app.config.auth.send(provider_key)
        provider provider_key, provider_config.api_key!, provider_config.api_secret!
        # puts "** configuring #{provider_key}: #{provider_config.api_key!}"
      end
      on_failure {|env| OmniAuth::FailureEndpointEx.new(env).redirect_to_failure }
    end
  end

end # module Auth
end # module Aerogel