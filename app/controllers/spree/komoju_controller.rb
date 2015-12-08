module Spree
  class KomojuController < ApplicationController
    protect_from_forgery except: :callback

    def callback
      return head :unauthorized unless callback_verified?

      case params[:type]
      when "ping"
        # do nothing
      when "payment.captured"
        order_number = extract_payment_number(params[:data][:external_order_num])
        payment = Spree::Payment.find_by_number!(order_number)
        payment.complete!
      else
        return head :unauthorized
      end

      head 200
    end

    private

    def extract_payment_number(external_order_num)
      external_order_num.split('-').try(:last)
    end

    def callback_verified?
      request_body = request.body.read
      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), SpreeKomoju.komoju_webhook_secret_token.to_s, request_body)
      Rack::Utils.secure_compare(signature, request.env["HTTP_X_KOMOJU_SIGNATURE"].to_s)
    end
  end
end
