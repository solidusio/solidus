# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/crud_resource_requests"

RSpec.describe "SolidusAdmin::ZonesController", type: :request do
  include_examples "CRUD resource requests", "zone" do
    let(:countries) { create_list(:country, 2) }
    let(:resource_class) { Spree::Zone }
    let(:valid_attributes) { { name: "Zone with countries", country_ids: countries.map(&:id) } }
    let(:invalid_attributes) { { name: "" } }

    it "creates new zone members" do
      expect { post solidus_admin.zones_path, params: { zone: valid_attributes } }.to change(Spree::ZoneMember, :count).by(countries.size)
    end

    it "updates zone members" do
      zone = create(:zone, :with_country)
      expect { patch solidus_admin.zone_path(zone), params: { zone: valid_attributes } }.to change(Spree::ZoneMember, :count).by(1)
    end
  end

  context "N+1" do
    before do
      create_list(:zone, 2, :with_country)
      create_list(:zone, 2, :with_state)
    end

    let(:expected_count) do
      [
        1, # count zones
        1, # select zones
        1, # preload zone_members
        1, # preload countries
        1, # preload states
        1, # select stores
      ].sum
    end

    it "is optimized" do
      expect { get solidus_admin.zones_path }.to make_database_queries(count: expected_count)
    end
  end
end
