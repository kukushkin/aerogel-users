module Aerogel
module Auth

  # known providers
  PROVIDERS = {
    password: { gem: nil },
    github: { gem: 'omniauth-github' },
    facebook: { gem: 'omniauth-facebook' },
    twitter: { gem: 'omniauth-twitter' },
    linkedin: { gem: 'omniauth-linkedin-oauth2' },
    vkontakte: { gem: 'omniauth-vkontakte' }
  }

  # Returns list of enabled omniauth providers as symbols.
  #
  # Example:
  #   Aerogel::Auth.enabled_providers # => [:password, :github, :twitter]
  #
  def self.enabled_providers
    return @enabled_providers unless @enabled_providers.nil?
    @enabled_providers = []
    PROVIDERS.each do |provider, opts|
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
      gem_name = PROVIDERS[provider_key][:gem]
      puts "** requiring #{provider_key}: #{gem_name}"
      require PROVIDERS[provider_key][:gem] if gem_name
    end
  end

  # Loads OmniAuth middleware with enabled providers.
  #
  def self.load_middleware( app )
    load_provider_gems
    app.use OmniAuth::Builder do
      puts "** configuring OmniAuth"
      provider :password, model: User
      Aerogel::Auth.enabled_providers.each do |provider_key|
        next if provider_key == :password
        provider_config = app.config.auth.send(provider_key)
        provider provider_key, provider_config.api_key!, provider_config.api_secret!
        puts "** configuring #{provider_key}: #{provider_config.api_key!}"
      end
      on_failure {|env| OmniAuth::FailureEndpointEx.new(env).redirect_to_failure }
    end
  end

end # module Auth
end # module Aerogel