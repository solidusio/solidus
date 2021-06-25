# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe Api::StockMovementsController, type: :request do
    let!(:stock_location) { create(:stock_location_with_items) }
    let!(:stock_item) { stock_location.stock_items.order(:id).first }
    let!(:stock_movement) { create(:stock_movement, stock_item: stock_item) }
    let!(:attributes) { [:id, :quantity, :stock_item_id] }

    before do
      stub_authentication!
    end

    context 'as a user' do
      it 'cannot see a list of stock movements' do
        get spree.api_stock_location_stock_movements_path(stock_location)
        expect(response.status).to eq(401)
      end

      it 'cannot see a stock movement' do
        get spree.api_stock_location_stock_movement_path(stock_location, stock_movement)
        expect(response.status).to eq(404)
      end

      it 'cannot create a stock movement' do
        params = {
          stock_movement: {
            stock_item_id: stock_item.to_param
          }
        }

        post spree.api_stock_location_stock_movements_path(stock_location), params: params
        expect(response.status).to eq(401)
      end
    end

    context 'as an admin' do
      sign_in_as_admin!

      it 'gets list of stock movements' do
        get spree.api_stock_location_stock_movements_path(stock_location)
        expect(json_response['stock_movements'].first).to have_attributes(attributes)
        expect(json_response['stock_movements'].first['stock_item']['count_on_hand']).to eq 11
      end

      it 'can control the page size through a parameter' do
        create(:stock_movement, stock_item: stock_item)
        get spree.api_stock_location_stock_movements_path(stock_location), params: { per_page: 1 }
        expect(json_response['count']).to eq(1)
        expect(json_response['current_page']).to eq(1)
        expect(json_response['pages']).to eq(2)
      end

      it 'can query the results through a paramter' do
        create(:stock_movement, :received, quantity: 10, stock_item: stock_item)
        get spree.api_stock_location_stock_movements_path(stock_location), params: { q: { quantity_eq: '10' } }
        expect(json_response['count']).to eq(1)
      end

      it 'gets a stock movement' do
        get spree.api_stock_location_stock_movement_path(stock_location, stock_movement)
        expect(json_response).to have_attributes(attributes)
        expect(json_response['stock_item_id']).to eq stock_movement.stock_item_id
      end

      it 'can create a new stock movement' do
        params = {
          stock_movement: {
            stock_item_id: stock_item.to_param
          }
        }

        post spree.api_stock_location_stock_movements_path(stock_location), params: params
        expect(response.status).to eq(201)
        expect(json_response).to have_attributes(attributes)
      end
    end
  end
end
