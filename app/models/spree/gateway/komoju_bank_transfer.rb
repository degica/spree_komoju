module Spree
  class Gateway::KomojuBankTransfer < KomojuGateway
    def authorize(money, source, options)
      details = {
        type:             "bank_transfer",
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
        expires_at:  response.params["payment_deadline"].to_time,
        order_id:    response.params["payment_details"]["order_id"],
        bank_number: response.params["payment_details"]["bank_number"],
        instructions_url: response.params["payment_details"]["instructions_url"]
      ) if response.success?
      response
    end

    def reusable_sources(*args)
      []
    end
  end
end
