module Spree
  class KomojuGateway < Gateway
    preference :api_key, :string

    def provider_class
      ActiveMerchant::Billing::KomojuGateway
    end

    def options
      super.merge(login: preferred_api_key, test: preferred_test_mode, locale: locale)
    end

    def auto_capture?
      false
    end

    def payment_profiles_supported?
      false
    end

    def supports?(source)
      true
    end

    # We need to change shipping, tax, subtotal and discount from cents to dollar for Komoju gateway.
    # Because, Komoju gateway supports JPY currency only.
    #
    # Spree changes price from dollar to cents. Almost payment gateway supports cents only.
    # See. https://github.com/spree/spree/blob/master/core/app/models/spree/payment/gateway_options.rb
    def change_options_to_dollar(options)
      %i(shipping tax subtotal discount).each { |key| options[key] = options[key] / 100.0 }
      options
    end

    def gateway_type
      self.class.to_s.split("::Komoju").last.underscore
    end

    def method_type
      "komoju_#{gateway_type}"
    end

    def payment_source_class
      "Spree::#{gateway_type.camelcase}".constantize
    end

    private

    def locale
      I18n.locale == :ja ? "ja" : "en"
    end
  end
end
