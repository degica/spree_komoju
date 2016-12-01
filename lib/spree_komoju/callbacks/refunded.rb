module SpreeKomoju
  module Callbacks
    class Refunded < Callback
      def process!
        return unless payment.completed?

        refunds.each do |refund_params|
          process_refund!(refund_params)
        end

        order.updater.update
      end

      private

      def process_refund!(refund_params)
        raise SpreeKomoju::Errors::IncorrectCurrency.new unless refund_params[:currency] == payment.currency

        refund_amount = ::Money.new(refund_params[:amount], refund_params[:currency]).to_f
        return if refund_amount > payment.credit_allowed

        refund_description = refund_params[:description].blank? ? "Komoju refund" : refund_params[:description]
        reason = Spree::RefundReason.find_or_create_by!(name: refund_description)
        payment.refunds.create!(amount: refund_amount, reason: reason, transaction_id: refund_params[:id])
      end

      def refunds
        params[:data][:refunds]
      end
    end
  end
end
