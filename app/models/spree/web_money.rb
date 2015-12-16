module Spree
  class WebMoney < Spree::Base
    belongs_to :payment_method
    belongs_to :user, class_name: Spree.user_class, foreign_key: 'user_id'
    has_many :payments, as: :source

    serialize :prepaid_cards, Array

    attr_accessor :prepaid_number
    validates :email, presence: true
    validates :prepaid_number, presence: true, on: :create

    def actions
      %w{capture}
    end

    def can_capture?(payment)
      return false unless ['checkout', 'pending'].include?(payment.state)
      payment.source.expires_at && (payment.source.expires_at > DateTime.current)
    end

    def can_void?(payment)
      false
    end

    def instructions_partial_path
      "spree/orders/web_money"
    end
  end
end
