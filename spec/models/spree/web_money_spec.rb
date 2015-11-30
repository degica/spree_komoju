require "spec_helper"

describe Spree::WebMoney, type: :model do
  subject { described_class.new }

  describe "#actions" do
    it { expect(subject.actions).to eq ["capture", "void"] }
  end

  describe "#can_capture?" do
    let(:payment) { double(Spree::Payment, state: state) }

    before do
      allow(subject).to receive(:payment) { payment }
    end

    context "when payment state is void" do
      let(:state) { "void" }

      it { expect(subject.can_capture?(payment)).to be_falsy }
    end

    context "when payment state is pending" do
      let(:state) { "pending" }

      it { expect(subject.can_capture?(payment)).to be_truthy }
    end
  end

  describe "#can_void?" do
    let(:payment) { double(Spree::Payment, state: state) }

    before do
      allow(subject).to receive(:payment) { payment }
    end

    context "when payment state is void" do
      let(:state) { "void" }

      it { expect(subject.can_void?(payment)).to be_falsy }
    end

    context "when payment state is pending" do
      let(:state) { "pending" }

      it { expect(subject.can_void?(payment)).to be_truthy }
    end
  end

  describe "#display_number" do
    it "returns display number" do
      subject.last_digits = "digi"

      expect(subject.display_number).to eq "XXXX-XXXX-XXXX-digi"
    end
  end

  describe "#set_last_digits" do
    it "sets last digits" do
      subject.prepaid_number = "prepaidnumber123"

      expect(subject.set_last_digits).to eq "r123"
    end
  end
end
