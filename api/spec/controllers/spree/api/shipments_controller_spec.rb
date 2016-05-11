require 'spec_helper'

describe Spree::Api::ShipmentsController, type: :controller do
  render_views
  let!(:shipment) { create(:shipment, inventory_units: [build(:inventory_unit, shipment: nil)]) }
  let!(:attributes) { [:id, :tracking, :tracking_url, :number, :cost, :shipped_at, :stock_location_name, :order_id, :shipping_rates, :shipping_methods] }

  before do
    stub_authentication!
  end

  let!(:resource_scoping) { { id: shipment.to_param, shipment: { order_id: shipment.order.to_param } } }

  context "as a non-admin" do
    it "cannot make a shipment ready" do
      api_put :ready
      assert_unauthorized!
    end

    it "cannot make a shipment shipped" do
      api_put :ship
      assert_unauthorized!
    end

    it "cannot remove order contents from shipment" do
      api_put :remove
      assert_unauthorized!
    end

    it "cannot add contents to the shipment" do
      api_put :add
      assert_unauthorized!
    end

    it "cannot update the shipment" do
      api_put :update
      assert_unauthorized!
    end
  end

  context "as an admin" do
    let!(:order) { shipment.order }
    let!(:stock_location) { create(:stock_location_with_items) }
    let!(:variant) { create(:variant) }

    sign_in_as_admin!

    # Start writing this spec a bit differently than before....
    describe 'POST #create' do
      let(:params) do
        {
          variant_id: stock_location.stock_items.first.variant.to_param,
          shipment: { order_id: order.number },
          stock_location_id: stock_location.to_param
        }
      end

      subject do
        api_post :create, params
      end

      [:variant_id, :stock_location_id].each do |field|
        context "when #{field} is missing" do
          before do
            params.delete(field)
          end

          it 'should return proper error' do
            subject
            expect(response.status).to eq(422)
            expect(json_response['exception']).to eq("param is missing or the value is empty: #{field}")
          end
        end
      end

      it 'should create a new shipment' do
        expect(subject).to be_ok
        expect(json_response).to have_attributes(attributes)
      end
    end

    it 'can update a shipment' do
      params = {
        shipment: {
          stock_location_id: stock_location.to_param
        }
      }

      api_put :update, params
      expect(response.status).to eq(200)
      expect(json_response['stock_location_name']).to eq(stock_location.name)
    end

    it "can make a shipment ready" do
      allow_any_instance_of(Spree::Order).to receive_messages(paid?: true, complete?: true)
      api_put :ready
      expect(json_response).to have_attributes(attributes)
      expect(json_response["state"]).to eq("ready")
      expect(shipment.reload.state).to eq("ready")
    end

    it "cannot make a shipment ready if the order is unpaid" do
      allow_any_instance_of(Spree::Order).to receive_messages(paid?: false)
      api_put :ready
      expect(json_response["error"]).to eq("Cannot ready shipment.")
      expect(response.status).to eq(422)
    end

    context 'for completed orders' do
      let(:order) { create :completed_order_with_totals }
      let!(:resource_scoping) { { id: order.shipments.first.to_param, shipment: { order_id: order.to_param } } }

      it 'adds a variant to a shipment' do
        api_put :add, { variant_id: variant.to_param, quantity: 2 }
        expect(response.status).to eq(200)
        expect(json_response['manifest'].detect { |h| h['variant']['id'] == variant.id }["quantity"]).to eq(2)
      end

      it 'removes a variant from a shipment' do
        order.contents.add(variant, 2)

        api_put :remove, { variant_id: variant.to_param, quantity: 1 }
        expect(response.status).to eq(200)
        expect(json_response['manifest'].detect { |h| h['variant']['id'] == variant.id }["quantity"]).to eq(1)
      end

      it 'removes a destroyed variant from a shipment' do
        order.contents.add(variant, 2)
        variant.destroy

        api_put :remove, { variant_id: variant.to_param, quantity: 1 }
        expect(response.status).to eq(200)
        expect(json_response['manifest'].detect { |h| h['variant']['id'] == variant.id }["quantity"]).to eq(1)
      end
    end

    context "for shipped shipments" do
      let(:order) { create :shipped_order }
      let!(:resource_scoping) { { id: order.shipments.first.to_param, shipment: { order_id: order.to_param } } }

      it 'adds a variant to a shipment' do
        api_put :add, { variant_id: variant.to_param, quantity: 2 }
        expect(response.status).to eq(200)
        expect(json_response['manifest'].detect { |h| h['variant']['id'] == variant.id }["quantity"]).to eq(2)
      end

      it 'cannot remove a variant from a shipment' do
        api_put :remove, { variant_id: variant.to_param, quantity: 1 }
        expect(response.status).to eq(422)
        expect(json_response['errors']['base'].join).to match /Cannot remove items/
      end
    end

    describe '#mine' do
      subject do
        api_get :mine, params
      end

      let(:params) { {} }

      context "the current api user is authenticated and has orders" do
        let(:current_api_user) { shipped_order.user }
        let(:shipped_order) { create(:shipped_order) }

        it 'succeeds' do
          subject
          expect(response.status).to eq 200
        end

        describe 'json output' do
          render_views

          let(:rendered_shipment_ids) { json_response['shipments'].map { |s| s['id'] } }

          it 'contains the shipments' do
            subject
            expect(rendered_shipment_ids).to match_array current_api_user.orders.flat_map(&:shipments).map(&:id)
          end

          context "credit card payment" do
            before { subject }

            it 'contains the id and cc_type of the credit card' do
              expect(json_response['shipments'][0]['order']['payments'][0]['source'].keys).to match_array ["id", "cc_type"]
            end
          end

          context "store credit payment" do
            let(:current_api_user) { shipped_order.user }
            let(:shipped_order)    { create(:shipped_order, payment_type: :store_credit_payment) }

            before { subject }

            it 'only contains the id of the payment source' do
              expect(json_response['shipments'][0]['order']['payments'][0]['source'].keys).to match_array ["id"]
            end
          end
        end

        context 'with filtering' do
          let(:params) { { q: { order_completed_at_not_null: 1 } } }

          let!(:incomplete_order) { create(:order_with_line_items, user: current_api_user) }

          it 'filters' do
            subject
            expect(assigns(:shipments).map(&:id)).to match_array current_api_user.orders.complete.flat_map(&:shipments).map(&:id)
          end
        end
      end

      context "the current api user does not exist" do
        let(:current_api_user) { nil }

        it "returns a 401" do
          subject
          expect(response.status).to eq(401)
        end
      end
    end
  end

  describe "#ship" do
    let(:shipment) { create(:order_ready_to_ship).shipments.first }

    let(:send_mailer) { nil }
    subject { api_put :ship, id: shipment.to_param, send_mailer: send_mailer }

    context "the user is allowed to ship the shipment" do
      sign_in_as_admin!
      it "ships the shipment" do
        Timecop.freeze do
          subject
          shipment.reload
          expect(shipment.state).to eq 'shipped'
          expect(shipment.shipped_at.to_i).to eq Time.current.to_i
        end
      end

      context "send_mailer not present" do
        it "sends the shipped shipments mailer" do
          expect { subject }.to change { ActionMailer::Base.deliveries.size }.by(1)
          expect(ActionMailer::Base.deliveries.last.subject).to match /Shipment Notification/
        end
      end

      context "send_mailer set to false" do
        let(:send_mailer) { 'false' }
        it "does not send the shipped shipments mailer" do
          expect { subject }.to_not change { ActionMailer::Base.deliveries.size }
        end
      end

      context "send_mailer set to true" do
        let(:send_mailer) { 'true' }
        it "sends the shipped shipments mailer" do
          expect { subject }.to change { ActionMailer::Base.deliveries.size }.by(1)
          expect(ActionMailer::Base.deliveries.last.subject).to match /Shipment Notification/
        end
      end
    end

    context "the user is not allowed to ship the shipment" do
      sign_in_as_admin!

      before do
        ability = Spree::Ability.new(current_api_user)
        ability.cannot :ship, Spree::Shipment
        allow(controller).to receive(:current_ability) { ability }
      end

      it "does nothing" do
        expect {
          expect {
            subject
          }.not_to change(shipment, :state)
        }.not_to change(shipment, :shipped_at)
      end

      it "responds with a 401" do
        subject
        expect(response.status).to eq 401
      end
    end

    context "the user is not allowed to view the shipment" do
      it "does nothing" do
        expect {
          expect {
            subject
          }.not_to change(shipment, :state)
        }.not_to change(shipment, :shipped_at)
      end

      it "responds with a 401" do
        subject
        expect(response).to be_unauthorized
      end
    end
  end
end
