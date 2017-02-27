require 'spec_helper'
require 'ostruct'

describe ActiveMerchant::Billing::KomojuGateway do
  before do
    setup
  end

  describe "when a gateway timeout occurs" do
    it "returns a spree error message" do
      response = OpenStruct.new({code: 504})
      expect(@gateway).to receive(:ssl_request).and_raise ActiveMerchant::ResponseError.new(response, "message")

      result = @gateway.purchase(@amount, @credit_card, @options)

      expect(result.params).to eq(gateway_timeout_error)
    end
  end

  private

  def gateway_timeout_error
    {
      "error" => {
        "code" => "gateway_timeout",
        "message" => "Payment could not be processed, please check the details you entered"
      }
    }
  end

  def credit_card
    ActiveMerchant::Billing::CreditCard.new({
      :number => '4111111111111111',
      :month => 3,
      :year => 2030,
      :first_name => 'Longbob',
      :last_name => 'Longsen',
      :verification_value => '123',
      :brand => 'visa'
    })
  end

  def setup
    @gateway = described_class.new(:login => 'login')

    @credit_card = credit_card
    @amount = 100

    @options = {
      :order_id => '1',
      :description => 'Store Purchase',
      :tax => "10",
      :ip => "192.168.0.1",
      :email => "valid@email.com",
      :browser_language => "en",
      :browser_user_agent => "user_agent"
    }
  end
end
