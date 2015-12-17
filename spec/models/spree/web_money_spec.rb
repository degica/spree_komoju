require "spec_helper"

describe Spree::WebMoney, type: :model do
  subject { described_class.new } 

  describe "#actions" do
    it { expect(subject.actions).to eq [] }
  end

  describe "#instructions_partial_path" do
    it { expect(subject.instructions_partial_path).to eq "spree/orders/web_money" }
  end
end
