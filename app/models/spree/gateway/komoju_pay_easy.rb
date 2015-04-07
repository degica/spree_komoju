module Spree
  class Gateway::KomojuPayEasy < KomojuGateway
    def authorize(money, source, options)
      details = {
        type:             "pay_easy",
        email:            source.email,
        phone:            source.phone,
        given_name:       source.given_name,
        family_name:      source.family_name,
        given_name_kana:  source.given_name_kana,
        family_name_kana: source.family_name_kana
      }
      options = change_options_to_dollar(options) if options[:currency] == "JPY"

      response = provider.purchase(money - options[:tax], details, options)

      source.update!(
        expires_at:       response.params["payment_deadline"].to_time,
        pay_url:          response.params["payment_details"]["pay_url"],
        instructions_url: response.params["payment_details"]["instructions_url"]
      )
      response
    end
  end
end
