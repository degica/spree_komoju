require "spec_helper"

describe Spree::Gateway::KomojuWebMoney, type: :model do
  subject { described_class.new }

  describe "#authorize" do
    let(:money) { 1000.0 }
    let(:source) { double("source", prepaid_number: "prepaid_number") }
    let(:options) { { login: "api_key", shipping: 100.0, tax: 200.0, subtotal: 800.0, discount: 100.0,
                      currency: currency } }
    let(:details) { { type: "web_money", prepaid_number: source.prepaid_number } }

    before do
      allow_any_instance_of(Spree::Gateway::KomojuWebMoney).to receive(:options) { options }
    end

    context "with currency is USD" do
      let(:currency) { "USD" }

      it "calls ActiveMerchant::Billing::KomojuGateway#purchase with original options" do
        response = double(ActiveMerchant::Billing::Response)
        expect_any_instance_of(ActiveMerchant::Billing::KomojuGateway).to receive(:purchase).with(800.0, details, options) { response }

        subject.authorize(money, source, options)
      end
    end

    context "with currency is JPY" do
      let(:currency) { "JPY" }

      it "calls ActiveMerchant::Billing::KomojuGateway#purchase with options converted from cents to dollars" do
        response = double(ActiveMerchant::Billing::Response)
        options_converted_to_dollars = { login: "api_key", shipping: 1.0, tax: 2.0, subtotal: 8.0, discount: 1.0,
                                         currency: currency }
        expect_any_instance_of(ActiveMerchant::Billing::KomojuGateway).to receive(:purchase).with(998.0, details, options_converted_to_dollars) { response }

        subject.authorize(money, source, options)
      end
    end
  end
end
