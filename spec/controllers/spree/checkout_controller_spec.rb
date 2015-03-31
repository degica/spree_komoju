require "spec_helper"

describe Spree::CheckoutController, type: :controller do
  describe "#permitted_source_attributes" do
    it "returns added attributes" do
      source_attributes = [:number, :month, :year, :expiry, :verification_value, :first_name, :last_name, :cc_type,
                           :gateway_customer_profile_id, :gateway_payment_profile_id, :last_digits, :name,
                           :encrypted_data, :convenience]
      expect(controller.permitted_source_attributes).to eq source_attributes
    end
  end
end
