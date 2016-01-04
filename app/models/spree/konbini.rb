module Spree
  class Konbini < Spree::Base
    STORES = %i(lawson family-mart sunkus circle-k ministop daily-yamazaki seven-eleven)

    belongs_to :payment_method
    belongs_to :user, class_name: Spree.user_class, foreign_key: 'user_id'
    has_many :payments, as: :source

    validates :convenience, presence: true

    def actions
      %w{}
    end

    def instructions_partial_path
      "spree/orders/konbini"
    end

    def imported
      false
    end

    def two_codes?
      %w[lawson family-mart ministop].include?(convenience)
    end
  end
end
