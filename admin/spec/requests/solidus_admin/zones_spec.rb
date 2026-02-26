# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/crud_resource_requests"

RSpec.describe "SolidusAdmin::ZonesController", type: :request do
  include_examples "CRUD resource requests", "zone" do
    let(:usa) { create(:country) }
    let(:canada) { create(:country, iso: "CA") }
    let(:countries) { [usa, canada] }
    let(:resource_class) { Spree::Zone }
    let(:valid_attributes) { {name: "Zone with countries", country_ids: countries.map(&:id)} }
    let(:invalid_attributes) { {name: ""} }

    it "creates new zone members" do
      expect { post solidus_admin.zones_path, params: {zone: valid_attributes} }.to change(Spree::ZoneMember, :count).by(countries.size)
    end

    it "updates zone members" do
      brazil = create(:country, iso: "BR")
      zone = create(:zone, countries: [brazil])
      expect { patch solidus_admin.zone_path(zone), params: {zone: valid_attributes} }.to change(Spree::ZoneMember, :count).by(1)
    end
  end

  context "N+1" do
    let(:usa) { create(:country) }
    let(:canada) { create(:country, iso: "CA") }
    let(:new_york) { create(:state, state_code: "NY", country: usa) }
    let(:north_carolina) { create(:state, state_code: "NC", country: usa) }
    let!(:usa_zone) { create(:zone, countries: [usa]) }
    let!(:canada_zone) { create(:zone, countries: [canada]) }
    let!(:new_york_zone) { create(:zone, states: [new_york]) }
    let!(:north_carolina_zone) { create(:zone, states: [north_carolina]) }

    let(:expected_count) do
      [
        1, # count zones
        1, # select zones
        1, # preload zone_members
        1, # preload countries
        1, # preload states
        1 # select stores
      ].sum
    end

    it "is optimized" do
      expect { get solidus_admin.zones_path }.to make_database_queries(count: expected_count)
    end
  end
end
