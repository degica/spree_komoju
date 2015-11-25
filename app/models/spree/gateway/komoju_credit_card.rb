module Spree
  class Gateway::KomojuCreditCard < KomojuGateway
    def auto_capture?
      true
    end

    def purchase(money, source, options)
      options = change_options_to_dollar(options) if options[:currency] == "JPY"
      if profile_id = source.gateway_payment_profile_id
        payment_details = profile_id
      else
        payment_details = source.to_active_merchant
      end
      super(money - options[:tax], payment_details, options)
    end
  end
end
