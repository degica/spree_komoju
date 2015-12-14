require "spec_helper"

describe WebMoneyDecorator, type: :model do
  context 'when source is webmoney' do
    it 'delegates methods' do
      source = Spree::WebMoney.new(prepaid_cards: [], short_amount: 1000, payment_uuid: "123")
      decorator = WebMoneyDecorator.new(source)

      expect(decorator.prepaid_cards).to eq([])
      expect(decorator.payment_uuid).to eq("123")
      expect(decorator.short_amount).to eq(1000)
    end
  end

  context 'when source is nill' do
    it 'delegates methods to nil' do
      decorator = WebMoneyDecorator.new(nil) 

      expect(decorator.prepaid_cards).to be_nil
      expect(decorator.payment_uuid).to be_nil
      expect(decorator.short_amount).to be_nil
    end
  end
end
