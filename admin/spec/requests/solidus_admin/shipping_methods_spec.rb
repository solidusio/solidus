# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/crud_resource_requests"

RSpec.describe "SolidusAdmin::ShippingMethodsController", type: :request do
  include_examples "CRUD resource requests", "shipping_method" do
    let(:shipping_category) { create(:shipping_category) }

    let(:resource_class) { Spree::ShippingMethod }
    let(:valid_attributes) do
      {
        name: "Express",
        calculator_type: "Spree::Calculator::Shipping::FlatRate",
        shipping_category_ids: [shipping_category.id]
      }
    end
    let(:invalid_attributes) { {name: ""} }
  end
end
