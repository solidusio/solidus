# frozen_string_literal: true

require 'spec_helper'

describe Spree::Api::ShipmentsController, type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let!(:shipment) { create(:shipment, inventory_units: [build(:inventory_unit, shipment: nil)]) }
  let!(:attributes) { [:id, :tracking, :tracking_url, :number, :cost, :shipped_at, :stock_location_name, :order_id, :shipping_rates, :shipping_methods] }

  before do
    stub_authentication!
  end

  let!(:resource_scoping) { { id: shipment.to_param, shipment: { order_id: shipment.order.to_param } } }

  context "as a non-admin" do
    it "cannot make a shipment ready" do
      put spree.ready_api_shipment_path(shipment)
      assert_unauthorized!
    end

    it "cannot make a shipment shipped" do
      put spree.ship_api_shipment_path(shipment)
      assert_unauthorized!
    end

    it "cannot remove order contents from shipment" do
      put spree.remove_api_shipment_path(shipment)
      assert_unauthorized!
    end

    it "cannot add contents to the shipment" do
      put spree.add_api_shipment_path(shipment)
      assert_unauthorized!
    end

    it "cannot update the shipment" do
      put spree.api_shipment_path(shipment)
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
        post spree.api_shipments_path, params: params
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
        subject
        expect(response).to be_ok
        expect(json_response).to have_attributes(attributes)
      end
    end

    it 'can update a shipment' do
      params = {
        shipment: {
          stock_location_id: stock_location.to_param
        }
      }

      put spree.api_shipment_path(shipment), params: params
      expect(response.status).to eq(200)
      expect(json_response['stock_location_name']).to eq(stock_location.name)
    end

    it "can make a shipment ready" do
      allow_any_instance_of(Spree::Order).to receive_messages(paid?: true, complete?: true)
      put spree.ready_api_shipment_path(shipment)
      expect(json_response).to have_attributes(attributes)
      expect(json_response["state"]).to eq("ready")
      expect(shipment.reload.state).to eq("ready")
    end

    it "cannot make a shipment ready if the order is unpaid" do
      allow_any_instance_of(Spree::Order).to receive_messages(paid?: false)
      put spree.ready_api_shipment_path(shipment)
      expect(json_response["error"]).to eq("Cannot ready shipment.")
      expect(response.status).to eq(422)
    end

    context 'for completed orders' do
      let(:order) { create :completed_order_with_totals }
      let(:shipment) { order.shipments.first }

      it 'adds a variant to a shipment' do
        put spree.add_api_shipment_path(shipment), params: { variant_id: variant.to_param, quantity: 2 }
        expect(response.status).to eq(200)
        expect(json_response['manifest'].detect { |h| h['variant']['id'] == variant.id }["quantity"]).to eq(2)
      end

      it 'removes a variant from a shipment' do
        order.contents.add(variant, 2)

        put spree.remove_api_shipment_path(shipment), params: { variant_id: variant.to_param, quantity: 1 }
        expect(response.status).to eq(200)
        expect(json_response['manifest'].detect { |h| h['variant']['id'] == variant.id }["quantity"]).to eq(1)
      end

      it 'removes a destroyed variant from a shipment' do
        order.contents.add(variant, 2)
        variant.discard

        put spree.remove_api_shipment_path(shipment), params: { variant_id: variant.to_param, quantity: 1 }
        expect(response.status).to eq(200)
        expect(json_response['manifest'].detect { |h| h['variant']['id'] == variant.id }["quantity"]).to eq(1)
      end
    end

    context 'for ready shipments' do
      let(:order) { create :order_ready_to_ship, line_items_attributes: [{ variant: variant, quantity: 1 }] }
      let(:shipment) { order.shipments.first }

      it 'adds a variant to a shipment' do
        put spree.add_api_shipment_path(shipment), params: { variant_id: variant.to_param, quantity: 1 }
        expect(response.status).to eq(200)
        expect(json_response['manifest'].detect { |h| h['variant']['id'] == variant.id }['quantity']).to eq(2)
      end

      it 'removes a variant from a shipment' do
        put spree.remove_api_shipment_path(shipment), params: { variant_id: variant.to_param, quantity: 1 }
        expect(response.status).to eq(200)
        expect(json_response['manifest'].detect { |h| h['variant']['id'] == variant.id }).to be nil
      end
    end

    context "for shipped shipments" do
      let(:order) { create :shipped_order }
      let(:shipment) { order.shipments.first }

      it 'adds a variant to a shipment' do
        put spree.add_api_shipment_path(shipment), params: { variant_id: variant.to_param, quantity: 2 }
        expect(response.status).to eq(200)
        expect(json_response['manifest'].detect { |h| h['variant']['id'] == variant.id }["quantity"]).to eq(2)
      end

      it 'cannot remove a variant from a shipment' do
        put spree.remove_api_shipment_path(shipment), params: { variant_id: variant.to_param, quantity: 1 }
        expect(response.status).to eq(422)
        expect(json_response['errors']['base'].join).to match /Cannot remove items/
      end
    end

    describe '#mine' do
      subject do
        get spree.mine_api_shipments_path, params: params
      end

      let(:params) { {} }

      context "the current api user is authenticated and has orders" do
        let(:current_api_user) { shipped_order.user }
        let!(:shipped_order) { create(:shipped_order) }

        it 'succeeds' do
          subject
          expect(response.status).to eq 200
        end

        describe 'json output' do
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

          context "check payment" do
            let(:current_api_user) { shipped_order.user }
            let(:shipped_order)    { create(:shipped_order, payment_type: :check_payment) }

            before { subject }

            it 'does not try to render a nil source' do
              expect(json_response['shipments'][0]['order']['payments'][0]['source']).to eq(nil)
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

  describe "#estimated_rates" do
    let!(:user_shipping_method) { shipment.shipping_method }
    let!(:admin_shipping_method) { create(:shipping_method, available_to_users: false, name: "Secret") }

    sign_in_as_admin!

    subject do
      get spree.estimated_rates_api_shipment_path(shipment)
    end

    it "returns success" do
      subject
      expect(response).to be_successful
    end

    it "returns rates available to user" do
      subject
      expect(json_response['shipping_rates']).to include(
        {
          "name" => user_shipping_method.name,
          "cost" => "100.0",
          "shipping_method_id" => user_shipping_method.id,
          "shipping_method_code" => user_shipping_method.code,
          "display_cost" => "$100.00"
        }
      )
    end

    it "returns rates available to admin" do
      subject
      expect(json_response['shipping_rates']).to include(
        {
          "name" => admin_shipping_method.name,
          "cost" => "10.0",
          "shipping_method_id" => admin_shipping_method.id,
          "shipping_method_code" => admin_shipping_method.code,
          "display_cost" => "$10.00"
        }
      )
    end
  end

  describe "#ship" do
    let(:shipment) { create(:order_ready_to_ship).shipments.first }

    let(:send_mailer) { nil }

    subject do
      put spree.ship_api_shipment_path(shipment), params: { send_mailer: send_mailer }
    end

    context "the user is allowed to ship the shipment" do
      sign_in_as_admin!
      it "ships the shipment" do
        now = Time.current
        travel_to(now) do
          subject
          shipment.reload
          expect(shipment.state).to eq 'shipped'
          expect(shipment.shipped_at.to_i).to eq now.to_i
        end
      end

      describe 'sent emails' do
        subject { perform_enqueued_jobs { super() } }

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
    end

    context "the user is not allowed to ship the shipment" do
      sign_in_as_admin!

      before do
        ability = Spree::Ability.new(current_api_user)
        ability.cannot :ship, Spree::Shipment
        allow_any_instance_of(Spree::Api::ShipmentsController).to receive(:current_ability) { ability }
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

  describe "transfers" do
    let(:user) { create(:admin_user, spree_api_key: 'abc123') }
    let(:current_api_user) { user }
    let(:stock_item) { create(:stock_item, backorderable: false) }
    let(:variant) { stock_item.variant }

    let(:order) do
      create(
        :completed_order_with_totals,
        user: user,
        line_items_attributes: [
          {
            variant: variant
          }
        ]
      )
    end

    let(:shipment) { order.shipments.first }

    describe "POST /api/shipments/transfer_to_location" do
      let(:stock_location) { create(:stock_location) }
      let(:source_shipment) { order.shipments.first }
      let(:parsed_response) { JSON.parse(response.body) }
      let(:stock_location_id) { stock_location.id }

      subject do
        post "/api/shipments/transfer_to_location.json",
          params: {
            original_shipment_number: source_shipment.number,
            stock_location_id: stock_location_id,
            quantity: 1,
            variant_id: variant.id,
            token: user.spree_api_key
          }
      end

      context "for a successful transfer" do
        before do
          stock_location.restock(variant, 1)
        end

        it "returns the correct message" do
          subject
          expect(response).to be_successful
          expect(parsed_response["success"]).to be true
          expect(parsed_response["message"]).to eq("Variants successfully transferred")
        end
      end

      context "for an unsuccessful transfer" do
        before do
          source_shipment
          variant
          stock_location.stock_items.update_all(backorderable: false)
        end

        it "returns the correct message" do
          subject
          expect(response).to be_accepted
          expect(parsed_response["success"]).to be false
          expect(parsed_response["message"]).to eq("Desired shipment not enough stock in desired stock location")
        end
      end

      context "if the source shipment can not be found" do
        let(:stock_location_id) { 9999 }

        it "returns a 404" do
          subject
          expect(response).to be_not_found
          expect(parsed_response["error"]).to eq("The resource you were looking for could not be found.")
        end
      end

      context "if the user can not update shipments" do
        let(:user) { create(:user, spree_api_key: 'abc123') }

        custom_authorization! do |_|
          can :read, Spree::Shipment
          cannot :update, Spree::Shipment
          can :create, Spree::Shipment
          can :destroy, Spree::Shipment
        end

        it "is not authorized" do
          subject
          expect(response).to be_unauthorized
        end
      end

      context "if the user can not destroy shipments" do
        let(:user) { create(:user, spree_api_key: 'abc123') }

        custom_authorization! do |_|
          can :read, Spree::Shipment
          can :update, Spree::Shipment
          cannot :destroy, Spree::Shipment
          can :create, Spree::Shipment
        end

        it "is not authorized" do
          subject
          expect(response).to be_unauthorized
        end
      end
    end

    describe "POST /api/shipments/transfer_to_shipment" do
      let(:stock_location) { create(:stock_location) }
      let(:source_shipment) { order.shipments.first }
      let(:target_shipment) { order.shipments.create(stock_location: stock_location) }
      let(:parsed_response) { JSON.parse(response.body) }
      let(:source_shipment_number) { source_shipment.number }

      subject do
        post "/api/shipments/transfer_to_shipment.json",
          params: {
            original_shipment_number: source_shipment_number,
            target_shipment_number: target_shipment.number,
            quantity: 1,
            variant_id: variant.id,
            token: user.spree_api_key
          }
      end

      context "for a successful transfer" do
        before do
          stock_location.restock(variant, 1)
        end

        it "returns the correct message" do
          subject
          expect(response).to be_accepted
          expect(parsed_response["success"]).to be true
          expect(parsed_response["message"]).to eq("Variants successfully transferred")
        end
      end

      context "if the source shipment can not be found" do
        let(:source_shipment_number) { 9999 }

        it "returns a 404" do
          subject
          expect(response).to be_not_found
          expect(parsed_response["error"]).to eq("The resource you were looking for could not be found.")
        end
      end
    end
  end
end
