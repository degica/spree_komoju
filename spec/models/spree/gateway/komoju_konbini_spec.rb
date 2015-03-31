require "spec_helper"

describe Spree::Gateway::KomojuKonbini, type: :model do
  subject { described_class.new }

  describe "#provider_class" do
    it { expect(subject.provider_class).to eq ActiveMerchant::Billing::KomojuGateway }
  end

  describe "#options" do
    it "returns options" do
      api_key = double("api_key")
      allow(subject).to receive(:preferred_api_key) { api_key }

      expect(subject.options).to eq ({ api_key: nil, server: "test", test_mode: true, login: api_key })
    end
  end

  describe "#authorize" do
    let(:money) { 1000.0 }
    let(:source) { Spree::Konbini.create!(convenience: "lawson") }
    let(:options) { { login: "api_key", shipping: 100.0, tax: 200.0, subtotal: 800.0, discount: 100.0,
                      currency: currency, billing_address: { phone: "09011112222" } } }
    let(:details) { { type: "konbini", store: "lawson", phone: "09011112222"  } }
    let(:response) { double(ActiveMerchant::Billing::Response, params: { "payment_deadline" => Time.now.iso8601.to_s }) }

    before do
      allow_any_instance_of(Spree::Gateway::KomojuKonbini).to receive(:options) { options }
    end

    context "with currency is USD" do
      let(:currency) { "USD" }

      it "calls ActiveMerchant::Billing::KomojuGateway#purchase" do
        expect_any_instance_of(ActiveMerchant::Billing::KomojuGateway).to receive(:purchase).with(800.0, details, options) { response }

        subject.authorize(money, source, options)
      end
    end

    context "with currency is JPY" do
      let(:currency) { "JPY" }

      it "calls ActiveMerchant::Billing::KomojuGateway#purchase" do
        changed_option =  { login: "api_key", shipping: 1.0, tax: 2.0, subtotal: 8.0, discount: 1.0, currency: currency,
                            billing_address: { phone: "09011112222" } }
        expect_any_instance_of(ActiveMerchant::Billing::KomojuGateway).to receive(:purchase).with(998.0, details, changed_option) { response }

        subject.authorize(money, source, options)
      end
    end
  end

  describe "#method_type" do
    it { expect(subject.method_type).to eq "komoju_konbini" }
  end

  describe "#auto_capture?" do
    it { expect(subject.auto_capture?).to be_falsy }
  end

  describe "#payment_source_class" do
    it { expect(subject.payment_source_class).to eq Spree::Konbini }
  end

  describe "#supports?" do
    it "returns true" do
      source = double("source")
      expect(subject.supports?(source)).to be_truthy
    end
  end
end
