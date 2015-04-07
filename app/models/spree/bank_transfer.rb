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

    def instruction
      Spree.t("instruction.bank_transfer", instruction_params)
    end

    def instruction_params
      {
        expires_at:  expires_at,
        bank_number: bank_number,
        order_id:    order_id
      }
    end
  end
end
