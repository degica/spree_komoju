module Spree
  class WebMoneyDecorator
    attr_reader :source
    delegate :short_amount, :prepaid_cards, :payment_uuid, to: :source,
      allow_nil: true

    def initialize(source)
      @source = if source.present? && source.brand == "web_moneys"
                  source
                else
                  nil
                end
    end
  end
end
