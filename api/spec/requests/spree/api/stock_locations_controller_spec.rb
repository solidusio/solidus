# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe Api::StockLocationsController, type: :request do
    let!(:stock_location) { create(:stock_location) }
    let!(:attributes) { [:id, :name, :address1, :address2, :city, :state_id, :state_name, :country_id, :zipcode, :phone, :active] }

    before do
      stub_authentication!
    end

    context "as a user" do
      describe "#index" do
        it "can see active stock locations" do
          get spree.api_stock_locations_path
          expect(response).to be_successful
          stock_locations = json_response['stock_locations'].map { |sl| sl['name'] }
          expect(stock_locations).to include stock_location.name
        end

        it "cannot see inactive stock locations" do
          stock_location.update!(active: false)
          get spree.api_stock_locations_path
          expect(response).to be_successful
          stock_locations = json_response['stock_locations'].map { |sl| sl['name'] }
          expect(stock_locations).not_to include stock_location.name
        end
      end

      describe "#show" do
        it "can see active stock locations" do
          get spree.api_stock_location_path(stock_location)
          expect(response).to be_successful
          expect(json_response['name']).to eq stock_location.name
        end

        it "cannot see inactive stock locations" do
          stock_location.update!(active: false)
          get spree.api_stock_location_path(stock_location)
          expect(response).to be_not_found
        end
      end

      describe "#create" do
        it "cannot create a new stock location" do
          params = {
            stock_location: {
              name: "North Pole",
              active: true
            }
          }

          post spree.api_stock_locations_path, params: params
          expect(response.status).to eq(401)
        end
      end

      describe "#update" do
        it "cannot update a stock location" do
          put spree.api_stock_location_path(stock_location), params: { stock_location: { name: "South Pole" } }
          expect(response.status).to eq(401)
        end
      end

      describe "#destroy" do
        it "cannot delete a stock location" do
          delete spree.api_stock_location_path(stock_location)
          expect(response.status).to eq(401)
        end
      end
    end

    context "as an admin" do
      sign_in_as_admin!

      describe "#index" do
        it "can see active stock locations" do
          get spree.api_stock_locations_path
          expect(response).to be_successful
          stock_locations = json_response['stock_locations'].map { |sl| sl['name'] }
          expect(stock_locations).to include stock_location.name
        end

        it "can see inactive stock locations" do
          stock_location.update!(active: false)
          get spree.api_stock_locations_path
          expect(response).to be_successful
          stock_locations = json_response['stock_locations'].map { |sl| sl['name'] }
          expect(stock_locations).to include stock_location.name
        end

        it "gets stock location information" do
          get spree.api_stock_locations_path
          expect(json_response['stock_locations'].first).to have_attributes(attributes)
          expect(json_response['stock_locations'].first['country']).not_to be_nil
          expect(json_response['stock_locations'].first['state']).not_to be_nil
        end

        it 'can control the page size through a parameter' do
          create(:stock_location)
          get spree.api_stock_locations_path, params: { per_page: 1 }
          expect(json_response['count']).to eq(1)
          expect(json_response['current_page']).to eq(1)
          expect(json_response['pages']).to eq(2)
        end

        it 'can query the results through a paramter' do
          expected_result = create(:stock_location, name: 'South America')
          get spree.api_stock_locations_path, params: { q: { name_cont: 'south' } }
          expect(json_response['count']).to eq(1)
          expect(json_response['stock_locations'].first['name']).to eq expected_result.name
        end
      end

      describe "#show" do
        it "can see active stock locations" do
          get spree.api_stock_location_path(stock_location)
          expect(response).to be_successful
          expect(json_response['name']).to eq stock_location.name
        end

        it "can see inactive stock locations" do
          stock_location.update!(active: false)
          get spree.api_stock_location_path(stock_location)
          expect(response).to be_successful
          expect(json_response['name']).to eq stock_location.name
        end
      end

      describe "#create" do
        it "can create a new stock location" do
          params = {
            stock_location: {
              name: "North Pole",
              active: true
            }
          }

          post spree.api_stock_locations_path, params: params
          expect(response.status).to eq(201)
          expect(json_response).to have_attributes(attributes)
        end
      end

      describe "#update" do
        it "can update a stock location" do
          params = {
            stock_location: {
              name: "South Pole"
            }
          }

          put spree.api_stock_location_path(stock_location), params: params
          expect(response.status).to eq(200)
          expect(json_response['name']).to eq 'South Pole'
        end
      end

      describe "#destroy" do
        it "can delete a stock location" do
          delete spree.api_stock_location_path(stock_location)
          expect(response.status).to eq(204)
          expect { stock_location.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
