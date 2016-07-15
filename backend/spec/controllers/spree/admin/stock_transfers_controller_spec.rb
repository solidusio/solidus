require 'spec_helper'

module Spree
  describe Admin::StockTransfersController, type: :controller do
    stub_authorization!

    let(:warehouse) { StockLocation.create(name: "Warehouse") }
    let(:ny_store) { StockLocation.create(name: "NY Store") }
    let(:la_store) { StockLocation.create(name: "LA Store") }

    context "#index" do
      let!(:stock_transfer1) {
        StockTransfer.create do |transfer|
          transfer.source_location_id = warehouse.id
          transfer.destination_location_id = ny_store.id
        end
      }

      let!(:stock_transfer2) {
        StockTransfer.create do |transfer|
          transfer.source_location_id = warehouse.id
          transfer.destination_location_id = la_store.id
          transfer.finalized_at = DateTime.current
          transfer.closed_at = DateTime.current
        end
      }

      describe "stock location filtering" do
        let(:user) { create(:admin_user) }
        let(:ability) { Spree::Ability.new(user) }
        let!(:sf_store) { StockLocation.create(name: "SF Store") }

        before do
          ability.cannot :manage, Spree::StockLocation
          ability.can :display, Spree::StockLocation, id: [warehouse.id]
          ability.can :display, Spree::StockLocation, id: [ny_store.id, la_store.id]

          allow_any_instance_of(Spree::Admin::BaseController).to receive(:spree_current_user).and_return(user)
          allow_any_instance_of(Spree::Admin::BaseController).to receive(:current_ability).and_return(ability)
        end

        it "doesn't display stock locations the user doesn't have access to" do
          get :index
          expect(assigns(:stock_locations)).to match_array [warehouse, ny_store, la_store]
        end
      end

      it "searches by stock location" do
        get :index, q: { source_location_id_or_destination_location_id_eq: ny_store.id }
        expect(assigns(:stock_transfers).count).to eq 1
        expect(assigns(:stock_transfers)).to include(stock_transfer1)
      end

      it "filters the closed stock transfers" do
        get :index, q: { closed_at_null: '1' }
        expect(assigns(:stock_transfers)).to match_array [stock_transfer1]
      end

      it "doesn't filter any stock transfers" do
        get :index, q: { closed_at_null: '0' }
        expect(assigns(:stock_transfers)).to match_array [stock_transfer1, stock_transfer2]
      end
    end

    context "#create" do
      let(:warehouse) { StockLocation.create(name: "Warehouse", active: false) }

      subject do
        post :create, stock_transfer: { source_location_id: warehouse.id, description: nil }
      end

      context "user doesn't have read access to the selected stock location" do
        before do
          expect(controller).to receive(:authorize!) { raise CanCan::AccessDenied }
        end

        it "redirects to authorization_failure" do
          subject
          expect(response).to redirect_to('/unauthorized')
        end
      end

      context "valid parameters" do
        let!(:user) { create(:user) }

        before do
          allow(controller).to receive(:try_spree_current_user) { user }
        end

        it "redirects to the edit page" do
          subject
          expect(response).to redirect_to(spree.edit_admin_stock_transfer_path(assigns(:stock_transfer)))
        end

        it "sets the created_by to the current user" do
          subject
          expect(assigns(:stock_transfer).created_by).to eq(user)
        end
      end

      # Regression spec for Solidus issue #1087
      context "missing source_stock_location parameter" do
        subject do
          post :create, stock_transfer: { source_location_id: nil, description: nil }
        end

        it "sets a flash error" do
          subject
          expect(flash[:error]).to eq assigns(:stock_transfer).errors.full_messages.join(', ')
        end
      end
    end

    context "#receive" do
      let!(:transfer_with_items) { create(:receivable_stock_transfer_with_items) }
      let(:variant_1)            { transfer_with_items.transfer_items[0].variant }
      let(:variant_2)            { transfer_with_items.transfer_items[1].variant }
      let(:parameters)           { { id: transfer_with_items.to_param } }

      subject do
        get :receive, parameters
      end

      context 'stock transfer is not receivable' do
        before do
          transfer_with_items.update_attributes(finalized_at: nil, shipped_at: nil)
        end

        it 'redirects back to index' do
          subject
          expect(flash[:error]).to eq Spree.t(:stock_transfer_must_be_receivable)
          expect(response).to redirect_to(spree.admin_stock_transfers_path)
        end
      end

      context "no items have been received" do
        let(:parameters) do
          { id: transfer_with_items.to_param }
        end

        before { subject }

        it "doesn't assign received_items" do
          expect(assigns(:received_items)).to be_empty
        end
      end

      context "some items have been received" do
        let(:transfer_item) { transfer_with_items.transfer_items.first }
        let(:parameters) do
          { id: transfer_with_items.to_param, variant_search_term: variant_1.sku }
        end

        before do
          transfer_item.update_attributes(received_quantity: 1)
          subject
        end

        it "assigns received_items correctly" do
          expect(assigns(:received_items)).to match_array [transfer_item]
        end
      end
    end

    context "#finalize" do
      let!(:user) { create(:user) }
      let!(:transfer_with_items) { create(:receivable_stock_transfer_with_items, finalized_at: nil, shipped_at: nil) }

      before do
        allow(controller).to receive(:try_spree_current_user) { user }
      end

      subject do
        put :finalize, id: transfer_with_items.to_param
      end

      context 'stock transfer is not finalizable' do
        before do
          transfer_with_items.update_attributes(finalized_at: Time.current)
        end

        it 'redirects back to edit' do
          subject
          expect(flash[:error]).to eq Spree.t(:stock_transfer_cannot_be_finalized)
          expect(response).to redirect_to(spree.edit_admin_stock_transfer_path(transfer_with_items))
        end
      end

      context "successfully finalized" do
        it "redirects to tracking_info" do
          subject
          expect(response).to redirect_to(spree.tracking_info_admin_stock_transfer_path(transfer_with_items))
        end

        it "sets the finalized_by to the current user" do
          subject
          expect(transfer_with_items.reload.finalized_by).to eq(user)
        end

        it "sets the finalized_at date" do
          subject
          expect(transfer_with_items.reload.finalized_at).to_not be_nil
        end
      end

      context "error finalizing the stock transfer" do
        before do
          transfer_with_items.update_attributes(destination_location_id: nil)
        end

        it "redirects back to edit" do
          subject
          expect(response).to redirect_to(spree.edit_admin_stock_transfer_path(transfer_with_items))
        end

        it "displays a flash error message" do
          subject
          expect(flash[:error]).to eq "Destination location can't be blank"
        end
      end
    end

    context "#close" do
      let!(:user) { create(:user) }
      let!(:transfer_with_items) { create(:receivable_stock_transfer_with_items) }

      before do
        allow(controller).to receive(:try_spree_current_user) { user }
      end

      subject do
        put :close, id: transfer_with_items.to_param
      end

      context 'stock transfer is not receivable' do
        before do
          transfer_with_items.update_attributes(finalized_at: nil, shipped_at: nil)
        end

        it 'redirects back to receive' do
          subject
          expect(flash[:error]).to eq Spree.t(:stock_transfer_must_be_receivable)
          expect(response).to redirect_to(spree.receive_admin_stock_transfer_path(transfer_with_items))
        end
      end

      context "successfully closed" do
        it "redirects back to index" do
          subject
          expect(response).to redirect_to(spree.admin_stock_transfers_path)
        end

        it "sets the closed_by to the current user" do
          subject
          expect(transfer_with_items.reload.closed_by).to eq(user)
        end

        it "sets the closed_at date" do
          subject
          expect(transfer_with_items.reload.closed_at).to_not be_nil
        end

        context "stock movements" do
          let(:source)          { transfer_with_items.source_location }
          let(:destination)     { transfer_with_items.destination_location }
          let(:transfer_item_1) { transfer_with_items.transfer_items[0] }
          let(:transfer_item_2) { transfer_with_items.transfer_items[1] }

          before do
            transfer_item_1.update_columns(received_quantity: 2)
            transfer_item_2.update_columns(received_quantity: 5)
            subject
          end

          it 'creates 2 stock movements' do
            expect(assigns(:stock_movements).length).to eq 2
          end

          it 'sets the stock transfer as the originator of the stock movements' do
            subject
            originators = assigns(:stock_movements).map(&:originator)
            expect(originators).to match_array [transfer_with_items, transfer_with_items]
          end

          it 'only creates stock movements for the destination stock location' do
            subject
            locations = assigns(:stock_movements).map(&:stock_item).flat_map(&:stock_location)
            expect(locations).to match_array [destination, destination]
          end

          it 'creates the stock movements for the received quantities' do
            subject
            movement_for_transfer_item_1 = assigns(:stock_movements).find { |sm| sm.stock_item.variant == transfer_item_1.variant }
            expect(movement_for_transfer_item_1.quantity).to eq 2
            movement_for_transfer_item_2 = assigns(:stock_movements).find { |sm| sm.stock_item.variant == transfer_item_2.variant }
            expect(movement_for_transfer_item_2.quantity).to eq 5
          end
        end
      end

      context "error closing the stock transfer" do
        before do
          transfer_with_items.update_columns(destination_location_id: nil)
        end

        it "redirects back to receive" do
          subject
          expect(response).to redirect_to(spree.receive_admin_stock_transfer_path(transfer_with_items))
        end

        it "displays a flash error message" do
          subject
          expect(flash[:error]).to eq "Destination location can't be blank"
        end
      end
    end

    context "#ship" do
      let(:stock_transfer) { Spree::StockTransfer.create(source_location: warehouse, destination_location: ny_store, created_by: create(:admin_user)) }
      let(:transfer_variant) { create(:variant) }
      let(:warehouse_stock_item) { warehouse.stock_items.find_by(variant: transfer_variant) }
      let(:ny_stock_item) { ny_store.stock_items.find_by(variant: transfer_variant) }

      subject { put :ship, id: stock_transfer.number }

      before do
        warehouse_stock_item.set_count_on_hand(1)
        stock_transfer.transfer_items.create!(variant: transfer_variant, expected_quantity: 1)
      end

      context "with transferable items" do
        it "marks the transfer shipped" do
          subject

          expect(stock_transfer.reload.shipped_at).to_not be_nil
          expect(flash[:success]).to be_present
        end

        it "makes stock movements for the transferred items" do
          subject

          expect(Spree::StockMovement.count).to eq 1
          expect(warehouse_stock_item.reload.count_on_hand).to eq 0
        end
      end

      context "with non-transferable items" do
        before { warehouse_stock_item.set_count_on_hand(0) }

        it "does not mark the transfer shipped" do
          subject

          expect(stock_transfer.reload.shipped_at).to be_nil
        end

        it "errors and redirects to tracking_info page" do
          subject

          expect(flash[:error]).to match /not enough inventory/
          expect(response).to redirect_to(spree.tracking_info_admin_stock_transfer_path(stock_transfer))
        end
      end
    end
  end
end
