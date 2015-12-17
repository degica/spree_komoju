module Spree
  class BankTransfer < Spree::Base
    belongs_to :payment_method
    belongs_to :user, class_name: Spree.user_class, foreign_key: 'user_id'
    has_many :payments, as: :source

    validates :email, :given_name, :family_name, :given_name_kana, :family_name_kana, presence: true

    def actions
      %w{}
    end

    def instructions_partial_path
      "spree/orders/bank_transfer"
    end

    def imported
      false
    end
  end
end
