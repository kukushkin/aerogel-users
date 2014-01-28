# Alternative FailureEndpoint for OmniAuth,
# which preserves all parameters passed to provider/callback
#
module OmniAuth
  class FailureEndpointEx < FailureEndpoint

    def redirect_to_failure
      message_key = env['omniauth.error.type']
      new_path = "#{env['SCRIPT_NAME']}#{OmniAuth.config.path_prefix}/failure?message=#{message_key}#{origin_query_param}#{strategy_name_query_param}#{extra_query_param}"
      Rack::Response.new(["302 Moved"], 302, 'Location' => new_path).finish
    end

    # Returns extra query params passed to callback.
    #
    def extra_query_param
      return "" unless env['omniauth.params']
      env['omniauth.params'].map{|k,v| "&#{k}=#{Rack::Utils.escape(v)}"}.join
    end

  end # class FailureEndpointEx < FailureEndpoint
end # module OmniAuth