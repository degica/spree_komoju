module Spree
  class KomojuController < ActionController::Base
    def callback
      order_number = params[:data][:external_order_num]
      transaction_id = params[:data][:id]

      if (order = Spree::Order.find_by(number: order_number))
        payment = order.payments.find_by(response_code: transaction_id)
        payment.capture!
      end

      render nothing: true, status: :ok
    end
  end
end
