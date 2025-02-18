# frozen_string_literal: true

require "spec_helper"
require 'solidus_admin/testing_support/shared_examples/crud_resource_requests'

RSpec.describe "SolidusAdmin::TaxCategoriesController", type: :request do
  include_examples 'CRUD resource requests', 'tax_category' do
    let(:resource_class) { Spree::TaxCategory }
    let(:valid_attributes) { { name: "Valid" } }
    let(:invalid_attributes) { { name: "" } }
  end
end
