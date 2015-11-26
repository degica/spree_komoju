module Spree
  class Gateway::KomojuKonbini < KomojuGateway
    def authorize(money, source, options)
      details = {
        type:  "konbini",
        store: source.convenience,
        phone: options[:billing_address][:phone],
        email: options[:email]
      }
      options = change_options_to_dollar(options) if options[:currency] == "JPY"

      response = provider.purchase(money - options[:tax], details, options)

      source.update!(
        expires_at:        response.params["payment_deadline"].to_time,
        receipt:           response.params["payment_details"]["receipt"],
        instructions_url:  response.params["payment_details"]["instructions_url"],
        confirmation_code: response.params["payment_details"]["confirmation_code"]
      )
      response
    end
  end
end
