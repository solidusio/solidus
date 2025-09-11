# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/crud_resource_requests"

RSpec.describe "SolidusAdmin::ShippingCategoriesController", type: :request do
  include_examples "CRUD resource requests", "shipping_category" do
    let(:resource_class) { Spree::ShippingCategory }
    let(:valid_attributes) { {name: "Express"} }
    let(:invalid_attributes) { {name: ""} }
  end
end
