require "spec_helper"

describe Spree::WebMoney, type: :model do
  subject { described_class.new } 

  describe "#actions" do
    it { expect(subject.actions).to eq ["capture"] }
  end

  describe "#can_capture?" do
    let(:payment) { double(Spree::Payment, state: state) }

    context "when payment state is pending" do
      context 'when payment is pending' do
        it 'returns true' do
          payment = double Spree::Payment, pending?: true, checkout?: false  
          expect(subject.can_capture?(payment)).to be_truthy
        end  
      end

      context 'when payment is in checkout state' do
        it 'returns true' do
          payment = double Spree::Payment, pending?: false, checkout?: true
          expect(subject.can_capture?(payment)).to be_truthy
        end  
      end

      context 'when payment is not in pending or checkout state' do
        it 'returns false' do
          payment = double Spree::Payment, pending?: false, checkout?: false
          expect(subject.can_capture?(payment)).to be_falsy
        end
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
