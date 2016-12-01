module Spree
  class KomojuController < ApplicationController
    protect_from_forgery except: :callback

    def callback
      return head :unauthorized unless callback_verified?

      case params[:type]
      when "payment.captured"
        payment_captured!
      when "payment.refunded"
        payment_refunded!
      end

      head 200
    end

    private

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

    def payment_captured!
      payment.complete! unless payment.completed?
    end

    def refund_params
      params[:data][:refunds].last
    end

    def refund_description
      refund_params[:description].blank? ? "Komoju refund" : refund_params[:description]
    end

    def refund_amount
      # Converts cents into dollars
      ::Money.new(refund_params[:amount], "USD").to_f
    end

    def payment_refunded!
      if payment.completed? && payment.credit_allowed >= refund_amount && payment.currency == refund_params[:currency]
        reason = Spree::RefundReason.find_or_create_by!(name: refund_description)
        payment.refunds.create!(amount: refund_amount, reason: reason, transaction_id: refund_params[:id])
        order.updater.update
      end
    end

    def callback_verified?
      request_body = request.body.read
      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), SpreeKomoju.komoju_webhook_secret_token.to_s, request_body)
      Rack::Utils.secure_compare(signature, request.env["HTTP_X_KOMOJU_SIGNATURE"].to_s)
    end
  end
end
