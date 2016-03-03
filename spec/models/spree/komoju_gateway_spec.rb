require "spec_helper"

describe Spree::KomojuGateway, type: :model do
  subject { described_class.new }

  describe "#provider_class" do
    it { expect(subject.provider_class).to eq ActiveMerchant::Billing::KomojuGateway }
  end

  describe "#options" do
    it "returns options" do
      api_key = double("api_key")
      allow(subject).to receive(:preferred_api_key) { api_key }
      allow(subject).to receive(:preferred_test) { true }

      expect(subject.options).to eq ({ api_key: nil, test: true, server: "test", test_mode: true, login: api_key, locale: "en" })
    end
  end

  describe "#auto_capture?" do
    it { expect(subject.auto_capture?).to be_falsy }
  end

  describe "#supports?" do
    it "returns true" do
      source = double("source")
      expect(subject.supports?(source)).to be_truthy
    end
  end

  describe "#change_options_to_dollar" do
    it "changes cents to dollar" do
      options = { shipping: 100, tax: 100, subtotal: 100, discount: 100 }

      expect(subject.change_options_to_dollar(options)).to eq ({ shipping: 1, tax: 1, subtotal: 1, discount: 1 })
    end
  end

  describe "#gateway_type" do
    it { expect(subject.gateway_type).to eq "gateway" }
  end

  describe "#method_type" do
    it { expect(subject.method_type).to eq "komoju_gateway" }
  end

  describe "#payment_source_class" do
    it { expect(subject.payment_source_class).to eq Spree::Gateway }
  end
end
