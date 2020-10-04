# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe Api::StockItemsController, type: :request do
    let!(:stock_location) { create(:stock_location_with_items) }
    let!(:stock_item) { stock_location.stock_items.order(:id).first }
    let!(:attributes) {
      [:id, :count_on_hand, :backorderable,
       :stock_location_id, :variant_id]
    }

    before do
      stub_authentication!
    end

    context "as a normal user" do
      describe "#index" do
        it "can list stock items for an active stock location" do
          get spree.api_stock_location_stock_items_path(stock_location)
          expect(response).to be_successful
          expect(json_response['stock_items'].first).to have_attributes(attributes)
          expect(json_response['stock_items'].first['variant']['sku']).to match /\ASKU-\d+\z/
        end

        it "cannot list stock items for an inactive stock location" do
          stock_location.update!(active: false)
          get spree.api_stock_location_stock_items_path(stock_location)
          expect(response).to be_not_found
        end
      end

      describe "#show" do
        it "can see a stock item for an active stock location" do
          get spree.api_stock_location_stock_item_path(stock_location, stock_item)
          expect(json_response).to have_attributes(attributes)
          expect(json_response['count_on_hand']).to eq stock_item.count_on_hand
        end

        it "cannot see a stock item for an inactive stock location" do
          stock_location.update!(active: false)
          get spree.api_stock_location_stock_item_path(stock_location, stock_item)
          expect(response.status).to eq(404)
        end
      end

      describe "#create" do
        it "cannot create a stock item" do
          variant = create(:variant)
          params = {
            stock_item: {
              variant_id: variant.id,
              count_on_hand: '20'
            }
          }

          post spree.api_stock_location_stock_items_path(stock_location), params: params
          expect(response.status).to eq(401)
        end
      end

      describe "#update" do
        it "cannot update a stock item" do
          put spree.api_stock_location_stock_item_path(stock_location, stock_item)
          expect(response.status).to eq(404)
        end
      end

      describe "#destroy" do
        it "cannot destroy a stock item" do
          delete spree.api_stock_location_stock_item_path(stock_location, stock_item)
          expect(response.status).to eq(404)
        end
      end
    end

    context "as an admin" do
      sign_in_as_admin!

      it 'can list stock items' do
        get spree.api_stock_location_stock_items_path(stock_location)
        expect(json_response['stock_items'].first).to have_attributes(attributes)
        expect(json_response['stock_items'].first['variant']['sku']).to include 'SKU'
      end

      it 'requires a stock_location_id to be passed as a parameter' do
        get spree.api_stock_items_path
        expect(json_response['exception']).to eq('param is missing or the value is empty: stock_location_id')
        expect(response.status).to eq(422)
      end

      it 'can control the page size through a parameter' do
        get spree.api_stock_location_stock_items_path(stock_location), params: { per_page: 1 }
        expect(json_response['count']).to eq(1)
        expect(json_response['current_page']).to eq(1)
      end

      it 'can query the results through a paramter' do
        stock_item.update_column(:count_on_hand, 30)
        get spree.api_stock_location_stock_items_path(stock_location), params: { q: { count_on_hand_eq: '30' } }
        expect(json_response['count']).to eq(1)
        expect(json_response['stock_items'].first['count_on_hand']).to eq 30
      end

      it 'gets a stock item' do
        get spree.api_stock_location_stock_item_path(stock_location, stock_item)
        expect(json_response).to have_attributes(attributes)
        expect(json_response['count_on_hand']).to eq stock_item.count_on_hand
      end

      context 'creating a stock item' do
        let!(:variant) do
          variant = create(:variant)
          # Creating a variant also creates stock items.
          # We don't want any to exist (as they would conflict with what we're about to create)
          StockItem.delete_all
          variant
        end
        let(:count_on_hand) { '20' }
        let(:params) do
          {
            stock_item: {
              variant_id: variant.id,
              count_on_hand: count_on_hand
            }
          }
        end

        subject do
          post spree.api_stock_location_stock_items_path(stock_location), params: params
        end

        it 'can create a new stock item' do
          subject
          expect(response.status).to eq 201
          expect(json_response).to have_attributes(attributes)
        end

        it 'creates a stock movement' do
          expect { subject }.to change { Spree::StockMovement.count }.by(1)
          expect(assigns(:stock_movement).quantity).to eq 20
        end

        context 'variant tracks inventory' do
          before do
            expect(variant.track_inventory).to eq true
          end

          it "sets the stock item's count_on_hand" do
            subject
            expect(assigns(:stock_item).count_on_hand).to eq 20
          end
        end

        context 'variant does not track inventory' do
          before do
            variant.update(track_inventory: false)
          end

          it "doesn't set the stock item's count_on_hand" do
            subject
            expect(assigns(:stock_item).count_on_hand).to eq 0
          end
        end

        context "attempting to set negative inventory" do
          let(:count_on_hand) { '-1' }

          it "does not allow negative inventory for the stock item" do
            subject
            expect(response.status).to eq 422
            expect(response.body).to match I18n.t('spree.api.stock_not_below_zero')
            expect(assigns(:stock_item).count_on_hand).to eq 0
          end
        end
      end

      context 'updating a stock item' do
        before do
          expect(stock_item.count_on_hand).to eq 10
        end

        subject do
          put spree.api_stock_item_path(stock_item), params: params
        end

        context 'adjusting count_on_hand' do
          let(:count_on_hand) { 40 }
          let(:params) do
            {
              stock_item: {
                count_on_hand: count_on_hand,
                backorderable: true
              }
            }
          end

          it 'can update a stock item to add new inventory' do
            subject
            expect(response.status).to eq 200
            expect(json_response['count_on_hand']).to eq 50
            expect(json_response['backorderable']).to eq true
          end

          it 'creates a stock movement for the adjusted quantity' do
            expect { subject }.to change { Spree::StockMovement.count }.by(1)
            expect(Spree::StockMovement.last.quantity).to eq 40
          end

          context 'tracking inventory' do
            before do
              expect(stock_item.should_track_inventory?).to eq true
            end

            it "sets the stock item's count_on_hand" do
             subject
             expect(assigns(:stock_item).count_on_hand).to eq 50
            end
          end

          context 'not tracking inventory' do
            before do
              stock_item.variant.update(track_inventory: false)
            end

            it "doesn't set the stock item's count_on_hand" do
              subject
              expect(assigns(:stock_item).count_on_hand).to eq 10
            end
          end

          context "attempting to set negative inventory" do
            let(:count_on_hand) { '-11' }

            it "does not allow negative inventory for the stock item" do
              subject
              expect(response.status).to eq 422
              expect(response.body).to match I18n.t('spree.api.stock_not_below_zero')
              expect(assigns(:stock_item).count_on_hand).to eq 10
            end
          end
        end

        context 'setting count_on_hand' do
          let(:count_on_hand) { 40 }
          let(:params) do
            {
              id: stock_item.to_param,
              stock_item: {
                count_on_hand: count_on_hand,
                backorderable: true,
                force: true
              }
            }
          end

          it 'can set a stock item to modify the current inventory' do
            subject
            expect(response.status).to eq 200
            expect(json_response['count_on_hand']).to eq 40
          end

          it 'creates a stock movement for the adjusted quantity' do
            expect { subject }.to change { Spree::StockMovement.count }.by(1)
            expect(assigns(:stock_movement).quantity).to eq 30
          end

          context 'tracking inventory' do
            before do
              expect(stock_item.should_track_inventory?).to eq true
            end

            it "updates the stock item's count_on_hand" do
              subject
              expect(assigns(:stock_item).count_on_hand).to eq 40
            end
          end

          context 'not tracking inventory' do
            before do
              stock_item.variant.update(track_inventory: false)
            end

            it "doesn't update the stock item's count_on_hand" do
              subject
              expect(assigns(:stock_item).count_on_hand).to eq 10
            end
          end

          context "attempting to set negative inventory" do
            let(:count_on_hand) { '-1' }

            it "does not allow negative inventory for the stock item" do
              subject
              expect(response.status).to eq 422
              expect(response.body).to match I18n.t('spree.api.stock_not_below_zero')
              expect(assigns(:stock_item).count_on_hand).to eq 10
            end
          end
        end
      end

      it 'can delete a stock item' do
        delete spree.api_stock_item_path(stock_item)
        expect(response.status).to eq(204)
        expect { Spree::StockItem.find(stock_item.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
