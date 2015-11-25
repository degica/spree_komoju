module Spree
  class Gateway::KomojuCreditCard < KomojuGateway
    def auto_capture?
      true
    end

    def purchase(money, source, options)
      options = change_options_to_dollar(options) if options[:currency] == "JPY"
      super(money - options[:tax], source.to_active_merchant, options)
    end
  end
end
