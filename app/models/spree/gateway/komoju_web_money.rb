module Spree
  class Gateway::KomojuWebMoney < KomojuGateway
    def authorize(money, source, options)
      details = { type: "web_money", prepaid_number: source.prepaid_number }
      options = change_options_to_dollar(options) if options[:currency] == "JPY"

      provider.purchase(money - options[:tax], details, options)
    end
  end
end
