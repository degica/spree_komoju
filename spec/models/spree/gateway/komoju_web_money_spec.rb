require "spec_helper"

describe Spree::Gateway::KomojuWebMoney do
  subject { described_class.new }

  describe "#auto_captured?" do
    it { should be_auto_capture }
  end 

  describe "#purchase" do
    let(:money) { 1000.0 }
    let(:source) { Spree::WebMoney.create!( email: "foo@bar.com", prepaid_number: "1111111111111111") }
    let(:options) { { login: "api_key", shipping: 100.0, tax: 200.0, subtotal: 800.0, discount: 100.0, order_id: "ORDERID-PAYMENTID", currency: "JPY" } }
    let(:order) { double Spree::Order, payments: [] }
    let(:response) { ActiveMerchant::Billing::Response.new(true, "success", response_params) }
    let(:response_params) do
      {
        "status" => "captured",
        "payment_deadline" => Time.now.iso8601.to_s,
        "payment_details" => {
          "short_amount" => 1000,
          "prepaid_cards" => [
            {
              "last_four_digits" => "1111",
              "points" => 100 
            }
          ]
        }
      }
    end

    context 'with valid parameters' do
      context 'when its a new webmoney request' do
        it "updates the source payment" do
          stub_order(order)
          expect_any_instance_of(ActiveMerchant::Billing::KomojuGateway).to receive(:purchase) { response }

          subject.purchase(money, source, options)
          expect(source.prepaid_cards).to eq([{"last_four_digits" => "1111", "points" => 100}])
          expect(source.short_amount).to eq(1000)
        end

        it "creates a payment with correct active merchant options" do
          stub_order(order)
          options_converted_to_dollars = options.merge({shipping: 1.0, tax: 2.0, subtotal: 8.0, discount: 1.0})
          payment_details = {type: "web_money", email: "foo@bar.com", prepaid_number: "1111111111111111"}
          expect_any_instance_of(ActiveMerchant::Billing::KomojuGateway).to receive(:purchase).with(998.0, payment_details, options_converted_to_dollars) { response }

          subject.purchase(money, source, options)
        end

        context 'when the status is pending' do
          it 'returns an insufficient funds error' do
            stub_order(order)
            expect_any_instance_of(ActiveMerchant::Billing::KomojuGateway).to receive(:purchase) { response }
            response_params["status"] = 'pending'

            response = subject.purchase(money, source, options)

            expect(response).to_not be_success
            expect(response.message).to eq(I18n.t('spree.komoju.web_money.insufficient_funds'))
          end  
        end
      end

      context 'when webmoney request is continued' do
        let(:webmoney) { double Spree::WebMoney, payment_uuid: "123" }
        let(:payment) { double Spree::Payment, source: webmoney }
        let(:order) { double Spree::Order, payments: [payment, payment] }

        it 'makes an activemerchant continue request' do
          stub_order(order)
          expect_any_instance_of(ActiveMerchant::Billing::KomojuGateway).to receive(:continue).
            with("123", {type: "web_money", email: "foo@bar.com", prepaid_number: "1111111111111111"}).
            and_return(response)

          subject.purchase(money, source, options)
        end

        it 'updates the prepaid cards hash on source' do
          stub_order(order)
          allow_any_instance_of(ActiveMerchant::Billing::KomojuGateway).
            to receive(:continue).and_return(response)

          subject.purchase(money, source, options)

          expect(source.prepaid_cards).to eq(response_params["payment_details"]["prepaid_cards"])
          expect(source.short_amount).to eq(response_params["payment_details"]["short_amount"])
        end
      end 
    end

    context 'with invalid parameters' do
      context 'when currency is not JPY' do
        it 'raises an unsupported currency exception' do
          expect {
            subject.purchase(nil, nil, currency: "USD") 
          }.to raise_error(SpreeKomoju::Errors::UnsupportedCurrency)
        end 
      end 
    end
  end

  def stub_order(order)
    allow_any_instance_of(Spree::Gateway::KomojuWebMoney).to receive(:options) { options }
    allow(Spree::Order).to receive(:find_by_number) { order }
  end
end
