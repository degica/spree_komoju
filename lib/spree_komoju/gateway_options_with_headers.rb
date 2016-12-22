module SpreeKomoju
  module GatewayOptionsWithHeaders
    def browser_language
      @payment.request_env.nil? ? "" : @payment.request_env["HTTP_ACCEPT_LANGUAGE"]
    end

    def browser_user_agent
      @payment.request_env.nil? ? "" : @payment.request_env["HTTP_USER_AGENT"]
    end

    # Prepended method
    def hash_methods
      super + [:browser_language, :browser_user_agent]
    end
  end
end
