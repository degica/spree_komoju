module Spree
  class Konbini < Spree::Base
    STORES = %i(lawson family-mart sunkus circle-k ministop daily-yamazaki seven-eleven)

    belongs_to :payment_method
    belongs_to :user, class_name: Spree.user_class, foreign_key: 'user_id'
    has_many :payments, as: :source

    validates :convenience, presence: true

    def actions
      %w{capture void}
    end

    def can_capture?(payment)
      return false unless ['checkout', 'pending'].include?(payment.state)
      payment.source.expires_at && (payment.source.expires_at > DateTime.current)
    end

    def can_void?(payment)
      payment.state != 'void'
    end

    def instruction
      params = {
        expires_at:        expires_at,
        receipt:           receipt,
        instructions_url:  instructions_url,
        confirmation_code: confirmation_code
      }
      Spree.t("instruction.konbini", params)
    end
  end
end
