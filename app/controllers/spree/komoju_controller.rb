module Spree
  class KomojuController < ApplicationController
    protect_from_forgery except: :callback

    def callback
      return head :unauthorized unless callback_verified?

      case params[:type]
      when "payment.captured"
        SpreeKomoju::Callbacks::Captured.new(params).process!
      when "payment.refunded"
        SpreeKomoju::Callbacks::Refunded.new(params).process!
      end

      head 200
    end

    private

    def callback_verified?
      request_body = request.body.read
      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), SpreeKomoju.komoju_webhook_secret_token.to_s, request_body)
      Rack::Utils.secure_compare(signature, request.env["HTTP_X_KOMOJU_SIGNATURE"].to_s)
    end
  end
end
