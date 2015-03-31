require "spec_helper"

describe Spree::KomojuController, type: :controller do
  routes { Spree::Core::Engine.routes }

  let(:payment_uuid) { "e013f92d24d26100670f0c2ae1" }
  let(:callback_params) do
    {
      type: callback_type,
      object: "event",
      data: {
        id: payment_uuid,
        resource: "payment",
        amount: 1000,
        tax: 80,
        payment_deadline: "2015-03-30T02:14:32Z",
        external_order_num: order_number,
        payment_details: {
          type: "konbini"
        },
        payment_method_fee: 0,
        total: 1080,
        currency: "JPY",
        description: nil,
        subscription: nil,
        succeeded: false,
        metadata: {},
        created_at: "2015-03-16T02:14:32Z"
      }
    }
  end

  describe "capture" do
    let(:callback_type) { "payment.captured" }
    context "order exists" do
      let!(:order) { create :completed_order_with_pending_payment }
      let(:order_number) { order.number }
      let(:payment) { order.payments.first }
      before do
        payment.response_code = payment_uuid
        payment.save!
      end

      it "captures payment" do
        expect_any_instance_of(Spree::Payment).to receive(:capture!)
        post :callback, callback_params
      end
    end
  end
end
