# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe Api::ZonesController, type: :request do
    let!(:attributes) { [:id, :name, :zone_members] }
    let!(:zone) { create(:zone, name: 'Europe') }

    before do
      stub_authentication!
    end

    it "gets list of zones" do
      get spree.api_zones_path
      expect(json_response['zones'].first).to have_attributes(attributes)
    end

    it 'can control the page size through a parameter' do
      create(:zone)
      get spree.api_zones_path, params: { per_page: 1 }
      expect(json_response['count']).to eq(1)
      expect(json_response['current_page']).to eq(1)
      expect(json_response['pages']).to eq(2)
    end

    it 'can query the results through a paramter' do
      expected_result = create(:zone, name: 'South America')
      get spree.api_zones_path, params: { q: { name_cont: 'south' } }
      expect(json_response['count']).to eq(1)
      expect(json_response['zones'].first['name']).to eq expected_result.name
    end

    it "gets a zone" do
      get spree.api_zone_path(zone)
      expect(json_response).to have_attributes(attributes)
      expect(json_response['name']).to eq zone.name
      expect(json_response['zone_members'].size).to eq zone.zone_members.count
    end

    context "as an admin" do
      sign_in_as_admin!

      it "can create a new zone" do
        params = {
          zone: {
            name: "North Pole",
            zone_members: [
              {
                zoneable_type: "Spree::Country",
                zoneable_id: 1
              }
            ]
          }
        }

        post spree.api_zones_path, params: params
        expect(response.status).to eq(201)
        expect(json_response).to have_attributes(attributes)
        expect(json_response["zone_members"]).not_to be_empty
      end

      it "updates a zone" do
        params = {
          zone: {
            name: "North Pole",
            zone_members: [
              {
                zoneable_type: "Spree::Country",
                zoneable_id: 1
              }
            ]
          }
        }

        put spree.api_zone_path(zone), params: params
        expect(response.status).to eq(200)
        expect(json_response['name']).to eq 'North Pole'
        expect(json_response['zone_members']).not_to be_blank
      end

      it "can delete a zone" do
        delete spree.api_zone_path(zone)
        expect(response.status).to eq(204)
        expect { zone.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
