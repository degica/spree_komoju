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

    def payment_refunded!
      if payment.completed?
        refund = params[:data][:refunds].last
        description = refund[:description].blank? ? "Komoju refund" : refund[:description]
        reason = Spree::RefundReason.find_or_create_by!(name: description)
        payment.refunds.create!(amount: payment.amount, reason: reason, transaction_id: refund[:id])
      end
    end

    def callback_verified?
      request_body = request.body.read
      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), SpreeKomoju.komoju_webhook_secret_token.to_s, request_body)
      Rack::Utils.secure_compare(signature, request.env["HTTP_X_KOMOJU_SIGNATURE"].to_s)
    end
  end
end
