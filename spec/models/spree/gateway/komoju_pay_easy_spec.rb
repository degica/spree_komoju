require "spec_helper"

describe Spree::Gateway::KomojuPayEasy, type: :model do
  subject { described_class.new }

  describe "#authorize" do
    let(:money) { 1000.0 }
    let(:source) do
      Spree::PayEasy.create!(
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
        type: "pay_easy",
        phone: nil,
        email: "email",
        given_name: "given_name",
        family_name: "family_name",
        given_name_kana: "given_name_kana",
        family_name_kana: "family_name_kana"
      }
    end
    let(:params) do
      {
        "payment_deadline" => Time.now.iso8601.to_s,
        "payment_details" => {
          "bank_id" => "bank_id",
          "customer_id" => "customer_id",
          "confirmation_id" => "confirmation_id",
          "instructions_url" => "instructions_url"
        }
      }
    end

    let(:response) { double(ActiveMerchant::Billing::Response, params: params, success?: true) }

    before do
      allow_any_instance_of(Spree::Gateway::KomojuPayEasy).to receive(:options) { options }
    end

    context "with currency is JPY" do
      let(:currency) { "JPY" }

      it 'updates the source payment' do
        expect_any_instance_of(ActiveMerchant::Billing::KomojuGateway).to receive(:purchase) { response }

        subject.authorize(money, source, options)
        expect(source.bank_id).to eq("bank_id")
        expect(source.customer_id).to eq("customer_id")
        expect(source.confirmation_id).to eq("confirmation_id")
        expect(source.instructions_url).to eq("instructions_url")
      end

      it "creates a payment with correct active merchant options" do
        options_converted_to_dollars = { login: "api_key", shipping: 1.0, tax: 2.0, subtotal: 8.0, discount: 1.0, currency: currency }
        expect_any_instance_of(ActiveMerchant::Billing::KomojuGateway).to receive(:purchase).with(998.0, details, options_converted_to_dollars) { response }

        subject.authorize(money, source, options)
      end
    end

    context "with currency is USD" do
      let(:currency) { "USD" }

      it "creates a payment with correct active merchant options" do
        expect_any_instance_of(ActiveMerchant::Billing::KomojuGateway).to receive(:purchase).with(800.0, details, options) { response }

        subject.authorize(money, source, options)
      end
    end

    context 'when response is not successful' do
      let(:currency) { "JPY" }

      it 'does not update the source payment' do
        response = double(ActiveMerchant::Billing::Response, params: params, success?: false)
        expect_any_instance_of(ActiveMerchant::Billing::KomojuGateway).to receive(:purchase) { response }

        subject.authorize(money, source, options)

        expect(source.instructions_url).to be_nil
      end
    end
  end
end
