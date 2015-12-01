require "spec_helper"

describe Spree::Gateway::KomojuKonbini, type: :model do
  subject { described_class.new }

  describe "#authorize" do
    let(:money) { 1000.0 }
    let(:source) { Spree::Konbini.create!(convenience: "lawson") }
    let(:options) { { email: "foo@example.com", login: "api_key", shipping: 100.0, tax: 200.0, subtotal: 800.0, discount: 100.0,
                      currency: currency, billing_address: { phone: "09011112222" } } }
    let(:details) { { type: "konbini", store: "lawson", phone: "09011112222", email: "foo@example.com"  } }
    let(:params) { { "payment_deadline" => Time.now.iso8601.to_s, "payment_details" => { "receipt" => "receipt", "instructions_url" => "instructions_url", "confirmation_code" => "confirmation_code"} } }
    let(:response) { double(ActiveMerchant::Billing::Response, params: params, success?: true) }

    before do
      allow_any_instance_of(Spree::Gateway::KomojuKonbini).to receive(:options) { options }
    end

    context "with currency is USD" do
      let(:currency) { "USD" }

      it "calls ActiveMerchant::Billing::KomojuGateway#purchase with original options" do
        expect_any_instance_of(ActiveMerchant::Billing::KomojuGateway).to receive(:purchase).with(800.0, details, options) { response }

        subject.authorize(money, source, options)
      end
    end

    context "with currency is JPY" do
      let(:currency) { "JPY" }

      it "calls ActiveMerchant::Billing::KomojuGateway#purchase with options converted from cents to dollars" do
        options_converted_to_dollars = { email: "foo@example.com", login: "api_key", shipping: 1.0, tax: 2.0, subtotal: 8.0, discount: 1.0,
                                         currency: currency, billing_address: { phone: "09011112222" } }
        expect_any_instance_of(ActiveMerchant::Billing::KomojuGateway).to receive(:purchase).with(998.0, details, options_converted_to_dollars) { response }

        subject.authorize(money, source, options)
      end
    end
  end
end
