require "spec_helper"

describe Spree::Gateway::KomojuCreditCard, type: :model do
  subject { described_class.new }
  let(:komoju_gateway) { double(ActiveMerchant::Billing::KomojuGateway, purchase: response) }
  let(:response) { double(ActiveMerchant::Billing::Response) }
  before do
    allow(ActiveMerchant::Billing::KomojuGateway).to receive(:new) { komoju_gateway }
  end

  describe "#purchase" do
    let(:money) { 1000.0 }
    let(:source) do
      double("credit card", gateway_payment_profile_id: payment_profile_id,
                            gateway_customer_profile_id: nil,
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

  describe "#create_profile" do
    let(:payment) { double("payment", source: source) }
    let(:details) { double("payment details") }

    context "source has credit card and no gateway_payment_profile_id" do
      let(:source) { double("credit card", gateway_payment_profile_id: nil,
                                           number: "4111111111111111",
                                           to_active_merchant: details) }
      before do
        allow(response).to receive(:params).and_return("id" => "tok_123")
        expect(komoju_gateway).to receive(:store).with(details, hash_including()) { response }
      end

      context "response is success" do
        before do
          allow(response).to receive(:success?).and_return(true)
          allow(source).to receive(:update_attributes!)
        end

        it "stores token" do
          subject.create_profile(payment)
        end

        it "updates source with payment profile id" do
          allow(komoju_gateway).to receive(:store).with(details, hash_including()) { response }
          expect(source).to receive(:update_attributes!).with(gateway_payment_profile_id: "tok_123")
          subject.create_profile(payment)
        end
      end

      context "response is failure" do
        before do
          allow(response).to receive(:success?).and_return(false)
          allow(response).to receive(:message).and_return("error message")
        end

        it "calls gateway_error on payment" do
          expect(payment).to receive(:gateway_error).with("error message")
          subject.create_profile(payment)
        end
      end
    end

    context "source has no number" do
      let(:source) { double("credit card", gateway_payment_profile_id: nil,
                                           number: nil,
                                           to_active_merchant: details) }

      it "does not try to store the payment details" do
        expect(komoju_gateway).not_to receive(:store)
        subject.create_profile(payment)
      end
    end

    context "source already has a payment profile id" do
      let(:source) { double("credit card", gateway_payment_profile_id: "tok_123",
                                           number: nil,
                                           to_active_merchant: details) }

      it "does not try to store the payment details" do
        expect(komoju_gateway).not_to receive(:store)
        subject.create_profile(payment)
      end
    end
  end
end
