module SpreeKomoju
  module Callbacks
    class Callback
      attr_reader :params

      def initialize(callback_params)
        @params = callback_params
      end

      protected

      def order_number
        params[:data][:external_order_num].split("-").try(:first)
      end

      def payment_number
        params[:data][:external_order_num].split("-").try(:last)
      end

      def order
        @order ||= Spree::Order.find_by_number!(order_number)
      end

      def payment
        @payment ||= order.payments.find_by_number!(payment_number)
      end
    end
  end
end
