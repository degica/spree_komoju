module Spree
  class Gateway::KomojuWebMoney < KomojuGateway
    def auto_capture?
      true
    end

    def purchase(money, source, options)
      raise SpreeKomoju::Errors::UnsupportedCurrency if options[:currency] != "JPY"

      details = {
        type: "web_money",
        email: source.email,
        prepaid_number: source.prepaid_number
      }
      options = change_options_to_dollar(options)

      if uuid = continue_uuid(options[:order_id])
        response = provider.continue(uuid, details)
      else
        response = provider.purchase(money - options[:tax], details, options)
      end

      source.update!(
        prepaid_cards: response.params["payment_details"]["prepaid_cards"],
        short_amount: response.params["payment_details"]["short_amount"]
      ) if response.success?

      if response.params["status"] == "pending"
        source.update!(payment_uuid: response.params["id"])
        response = multi_card_response(response)
      end

      response
    end

    private

    def multi_card_response(response)
      response.instance_variable_set(:@success, false)
      response.instance_variable_set(:@message, I18n.t('spree.komoju.web_money.insufficient_funds'))
      response
    end

    def continue_uuid(current_order_id)
      order = Spree::Order.find_by_number(current_order_id.split('-').first)
      
      # NOTE: Since the current payment is this payment, find the payment before
      # and see if it was for a webmoney transaction. If it was check if it has a payment UUID
      # to continue the transaction.
      source = WebMoneyDecorator.new(order.payments.last(2).first.try(:source))
      source.payment_uuid
    end
  end
end
