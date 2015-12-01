require "spec_helper"

describe Spree::Gateway::KomojuCreditCard, type: :model do
  subject { described_class.new }

  describe "#purchase" do
    let(:money) { 1000.0 }
    let(:source) do
      double("credit card", gateway_payment_profile_id: payment_profile_id,
                            to_active_merchant: details)
    end
    let(:currency) { "JPY" }
    let(:details) { double("payment details") }
    let(:options) do
      {
        email: "foo@example.com",
        login: "api_key",
        shipping: 100.0,
        tax: 200.0,
        subtotal: 800.0,
        discount: 100.0,
        currency: currency,
        billing_address: { phone: "09011112222" }
      }
    end
    let(:komoju_gateway) { double(ActiveMerchant::Billing::KomojuGateway, purchase: response) }
    let(:response) { double(ActiveMerchant::Billing::Response) }
    before do
      allow(ActiveMerchant::Billing::KomojuGateway).to receive(:new) { komoju_gateway }
    end

    context "with no payment profile id" do
      let(:payment_profile_id) { nil }

      it "calls provider#purchase with original options" do
        expect(komoju_gateway).to receive(:purchase).with(998.0, details, options) { response }
        expect(subject.purchase(money, source, options)).to eq(response)
      end
    end

    context "with a payment profile id" do
      let(:payment_profile_id) { "tok_123" }

      it "calls provider#purchase with profile id" do
        expect(komoju_gateway).to receive(:purchase).with(998.0, "tok_123", options) { response }
        expect(subject.purchase(money, source, options)).to eq(response)
      end
    end
  end
end
