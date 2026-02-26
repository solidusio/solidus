# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/crud_resource_requests"

RSpec.describe "SolidusAdmin::StockLocationsController", type: :request do
  include_examples "CRUD resource requests", "stock_location" do
    before { create(:country, iso: "US") }

    let(:resource_class) { Spree::StockLocation }
    let(:valid_attributes) { {name: "Warehouse"} }
    let(:invalid_attributes) { {name: ""} }
  end
end
