module Spree
  class Gateway::KomojuCreditCard < KomojuGateway
    def auto_capture?
      true
    end

    def purchase(money, source, options)
      options = change_options_to_dollar(options) if options[:currency] == "JPY"
      if profile_id = source.gateway_payment_profile_id || source.gateway_customer_profile_id
        payment_details = profile_id
      else
        payment_details = source.to_active_merchant
      end
      super(money - options[:tax], payment_details, options)
    end

    # enable either token-based profiles or customer-based profiles
    def create_profile(payment)
      return unless payment.source.number.present?
      profile_id_name = SpreeKomoju.enable_customer_profiles ? :gateway_customer_profile_id : :gateway_payment_profile_id
      profile_id = payment.source.public_send(profile_id_name)
      if profile_id.nil?
        response = provider.store(payment.source.to_active_merchant,
                                  options.merge(customer_profile: (profile_id_name == :gateway_customer_profile_id)))

        if response.success?
          payment.source.update_attributes!(profile_id_name => response.params['id'])
        else
          payment.send(:gateway_error, response.message)
        end
      end
    end
  end
end
