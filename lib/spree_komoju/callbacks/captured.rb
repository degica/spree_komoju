module SpreeKomoju
  module Callbacks
    class Captured < Callback
      def process!
        payment.complete! unless payment.completed?
      end
    end
  end
end
