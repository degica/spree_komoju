module Spree
  class BankTransfer < Spree::Base
    belongs_to :payment_method
    belongs_to :user, class_name: Spree.user_class, foreign_key: 'user_id'
    has_many :payments, as: :source

    validates :email, :given_name, :family_name, :given_name_kana, :family_name_kana, presence: true

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

    def instructions_partial_path
      "spree/orders/bank_transfer"
    end
  end
end
