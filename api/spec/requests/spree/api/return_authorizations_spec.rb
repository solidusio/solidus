# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe Api::ReturnAuthorizationsController, type: :request do
    let!(:order) { create(:shipped_order) }

    let(:product) { create(:product) }
    let(:attributes) { [:id, :memo, :state] }

    before do
      stub_authentication!
    end

    shared_examples_for 'a return authorization creator' do
      it "can create a new return authorization" do
        stock_location = FactoryBot.create(:stock_location)
        reason = FactoryBot.create(:return_reason)
        reimbursement = FactoryBot.create(:reimbursement_type)
        unit = FactoryBot.create(:inventory_unit)
        rma_params = { stock_location_id: stock_location.id,
                       return_reason_id: reason.id,
                       return_items_attributes: [{
                         inventory_unit_id: unit.id,
                         preferred_reimbursement_type_id: reimbursement.id,
                       }],
                       memo: "Defective" }
        post spree.api_order_return_authorizations_path(order), params: { order_id: order.number, return_authorization: rma_params }
        expect(response.status).to eq(201)
        expect(json_response).to have_attributes(attributes)
        expect(json_response["state"]).not_to be_blank
        return_authorization = Spree::ReturnAuthorization.last
        expect(return_authorization.return_items.first.preferred_reimbursement_type).to eql reimbursement
      end
    end

    context "as the order owner" do
      before do
        allow_any_instance_of(Order).to receive_messages user: current_api_user
      end

      it "cannot see any return authorizations" do
        get spree.api_order_return_authorizations_path(order)
        assert_unauthorized!
      end

      it "cannot see a single return authorization" do
        get spree.api_order_return_authorization_path(order, 1)
        assert_unauthorized!
      end

      it "cannot learn how to create a new return authorization" do
        get spree.new_api_order_return_authorization_path(order)
        assert_unauthorized!
      end

      it_behaves_like "a return authorization creator"

      it "cannot update a return authorization" do
        put spree.api_order_return_authorization_path(order, 0)
        assert_not_found!
      end

      it "cannot delete a return authorization" do
        delete spree.api_order_return_authorization_path(order, 0)
        assert_not_found!
      end
    end

    context "as another non-admin user that's not the order's owner" do
      before do
        allow_any_instance_of(Order).to receive_messages user: create(:user)
      end

      it "cannot create a new return authorization" do
        post spree.api_order_return_authorizations_path(order)
        assert_unauthorized!
      end
    end

    context "as an admin" do
      sign_in_as_admin!

      it "can show return authorization" do
        FactoryBot.create(:return_authorization, order: order)
        return_authorization = order.return_authorizations.first
        get spree.api_order_return_authorization_path(order, return_authorization.id)
        expect(response.status).to eq(200)
        expect(json_response).to have_attributes(attributes)
        expect(json_response["state"]).not_to be_blank
      end

      it "can get a list of return authorizations" do
        FactoryBot.create(:return_authorization, order: order)
        FactoryBot.create(:return_authorization, order: order)
        get spree.api_order_return_authorizations_path(order), params: { order_id: order.number }
        expect(response.status).to eq(200)
        return_authorizations = json_response["return_authorizations"]
        expect(return_authorizations.first).to have_attributes(attributes)
        expect(return_authorizations.first).not_to eq(return_authorizations.last)
      end

      it 'can control the page size through a parameter' do
        FactoryBot.create(:return_authorization, order: order)
        FactoryBot.create(:return_authorization, order: order)
        get spree.api_order_return_authorizations_path(order), params: { order_id: order.number, per_page: 1 }
        expect(json_response['count']).to eq(1)
        expect(json_response['current_page']).to eq(1)
        expect(json_response['pages']).to eq(2)
      end

      it 'can query the results through a paramter' do
        FactoryBot.create(:return_authorization, order: order)
        expected_result = create(:return_authorization, memo: 'damaged')
        order.return_authorizations << expected_result
        get spree.api_order_return_authorizations_path(order), params: { q: { memo_cont: 'damaged' } }
        expect(json_response['count']).to eq(1)
        expect(json_response['return_authorizations'].first['memo']).to eq expected_result.memo
      end

      it "can learn how to create a new return authorization" do
        get spree.new_api_order_return_authorization_path(order)
        expect(json_response["attributes"]).to eq(["id", "number", "state", "order_id", "memo", "created_at", "updated_at"])
        required_attributes = json_response["required_attributes"]
        expect(required_attributes).to include("order")
      end

      it "can update a return authorization on the order" do
        FactoryBot.create(:return_authorization, order: order)
        return_authorization = order.return_authorizations.first
        put spree.api_order_return_authorization_path(order, return_authorization.id), params: { return_authorization: { memo: "ABC" } }
        expect(response.status).to eq(200)
        expect(json_response).to have_attributes(attributes)
      end

      it "can cancel a return authorization on the order" do
        FactoryBot.create(:new_return_authorization, order: order)
        return_authorization = order.return_authorizations.first
        expect(return_authorization.state).to eq("authorized")
        put spree.cancel_api_order_return_authorization_path(order, return_authorization.id)
        expect(response.status).to eq(200)
        expect(return_authorization.reload.state).to eq("canceled")
      end

      it "can delete a return authorization on the order" do
        FactoryBot.create(:return_authorization, order: order)
        return_authorization = order.return_authorizations.first
        delete spree.api_order_return_authorization_path(order, return_authorization.id)
        expect(response.status).to eq(204)
        expect { return_authorization.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it_behaves_like "a return authorization creator"
    end

    context "as just another user" do
      it "cannot add a return authorization to the order" do
        post spree.api_order_return_authorizations_path(order), params: { return_autorization: { order_id: order.number, memo: "Defective" } }
        assert_unauthorized!
      end

      it "cannot update a return authorization on the order" do
        FactoryBot.create(:return_authorization, order: order)
        return_authorization = order.return_authorizations.first
        put spree.api_order_return_authorization_path(order, return_authorization.id), params: { return_authorization: { memo: "ABC" } }
        assert_unauthorized!
        expect(return_authorization.reload.memo).not_to eq("ABC")
      end

      it "cannot delete a return authorization on the order" do
        FactoryBot.create(:return_authorization, order: order)
        return_authorization = order.return_authorizations.first
        delete spree.api_order_return_authorization_path(order, return_authorization.id)
        assert_unauthorized!
        expect { return_authorization.reload }.not_to raise_error
      end
    end
  end
end
