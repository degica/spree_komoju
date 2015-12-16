require "spec_helper"

describe Spree::WebMoney, type: :model do
  subject { described_class.new } 

  describe "#actions" do
    it { expect(subject.actions).to eq ["capture"] }
  end

  describe "#can_capture?" do
    let(:payment) { double(Spree::Payment, state: state) }

    before do
      allow(subject).to receive(:payment) { payment }
    end

    context "when payment state is not checkout or pending" do
      let(:state) { "void" }

      it { expect(subject.can_capture?(payment)).to be_falsy }
    end

    context "when payment state is pending" do
      let(:payment) { double(Spree::Payment, state: state, source: source) }
      let(:state) { "pending" }
      let(:source) { double(Spree::WebMoney, expires_at: expires_at) }

      before do
        allow(subject).to receive(:payment) { payment }
      end

      context "when expires_at is tomorrow" do
        let(:expires_at) { Date.tomorrow }

        it { expect(subject.can_capture?(payment)).to be_truthy }
      end

      context "when expires_at is yesterday" do
        let(:expires_at) { Date.yesterday}

        it { expect(subject.can_capture?(payment)).to be_falsy }
      end
    end
  end

  describe "#can_void?" do
    it 'returns false' do
      expect(subject.can_void?(nil)).to be(false)
    end
  end

  describe "#instructions_partial_path" do
    it { expect(subject.instructions_partial_path).to eq "spree/orders/web_money" }
  end
end
