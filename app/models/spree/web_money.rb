module Spree
  class WebMoney < Spree::Base
    belongs_to :payment_method
    belongs_to :user, class_name: Spree.user_class, foreign_key: 'user_id'
    has_many :payments, as: :source

    before_save :set_last_digits

    attr_accessor :prepaid_number

    def actions
      %w{capture void}
    end

    def can_capture?(payment)
      ['checkout', 'pending'].include?(payment.state)
    end

    def can_void?(payment)
      payment.state != 'void'
    end

    # Show the prepaid number, with all but last 4 numbers replace with "X". (XXXX-XXXX-XXXX-4338)
    def display_number
      "XXXX-XXXX-XXXX-#{last_digits}"
    end

    def set_last_digits
      self.last_digits ||= prepaid_number.to_s.length <= 4 ? prepaid_number : prepaid_number.to_s.slice(-4..-1)
    end
  end
end
