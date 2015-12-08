require "spec_helper"

describe Spree::KomojuController, type: :controller do
  routes { Spree::Core::Engine.routes }

  describe "#callback" do
    context 'when callback is verified' do
      before do
        allow(OpenSSL::HMAC).to receive(:hexdigest) { "signature" }
        request.env["HTTP_X_KOMOJU_SIGNATURE"] = "signature"
      end

      context 'when type is ping' do
        it 'returns a successful response' do
          post :callback, {type: "ping"}

          expect(response.status).to eq(200)
        end
      end

      context 'when type is payment.captured' do
        let(:payment) { double Spree::Payment, complete!: true }
        let(:capture_params) do
          {
            "type" => "payment.captured",
            "data" => {
              "external_order_num" => "SPREEORDER-PAYMENTID"
            }
          }
        end

        context 'when payment exists' do
          it 'marks a payment as complete' do
            allow(Spree::Payment).to receive(:find_by_number!) { payment }

            post :callback, capture_params

            expect(payment).to have_received(:complete!)
          end 
        end

        context 'when payment doesnt exist' do
          it 'raises an activerecord error' do
            expect {
              post :callback, capture_params
            }.to raise_error(ActiveRecord::RecordNotFound)
          end    
        end
      end

      context 'when type is not recognized' do
        it 'returns an unauthorized status code' do
          post :callback, {type: "bad_type"} 
          expect(response.status).to eq(401)
        end 
      end
    end  

    context 'when callback is unverified' do
      it 'returns head unauthorized' do
        post :callback
        expect(response.status).to eq(401)
      end 
    end
  end
end
