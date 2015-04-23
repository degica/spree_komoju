require "spec_helper"

describe Spree::Gateway::KomojuBankTransfer, type: :model do
  subject { described_class.new }

  describe "#authorize" do
    let(:money) { 1000.0 }
    let(:source) do
      Spree::BankTransfer.create!(
        email: "email",
        given_name: "given_name",
        family_name: "family_name",
        given_name_kana: "given_name_kana",
        family_name_kana: "family_name_kana"
      )
    end
    let(:options) { { login: "api_key", shipping: 100.0, tax: 200.0, subtotal: 800.0, discount: 100.0,
                      currency: currency } }
    let(:details) do
      {
        type: "bank_transfer",
        phone: nil,
        email: "email",
        given_name: "given_name",
        family_name: "family_name",
        given_name_kana: "given_name_kana",
        family_name_kana: "family_name_kana"
      }
    end
    let(:params) { { "payment_deadline" => Time.now.iso8601.to_s, "payment_details" => { "order_id" => "order_id", "bank_transfer" => "bank_transfer" } } }
    let(:response) { double(ActiveMerchant::Billing::Response, params: params) }

    before do
      allow_any_instance_of(Spree::Gateway::KomojuBankTransfer).to receive(:options) { options }
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
        options_converted_to_dollars = { login: "api_key", shipping: 1.0, tax: 2.0, subtotal: 8.0, discount: 1.0,
                                         currency: currency }
        expect_any_instance_of(ActiveMerchant::Billing::KomojuGateway).to receive(:purchase).with(998.0, details, options_converted_to_dollars) { response }

        subject.authorize(money, source, options)
      end
    end
  end
end
