# frozen_string_literal: true

require "spec_helper"
require 'solidus_admin/testing_support/shared_examples/crud_resource_requests'

RSpec.describe "SolidusAdmin::TaxRatesController", type: :request do
  include_examples 'CRUD resource requests', 'tax_rate' do
    let(:resource_class) { Spree::TaxRate }
    let(:valid_attributes) { { amount: 1, calculator_type: "Spree::Calculator::DefaultTax" } }
    let(:invalid_attributes) { { amount: "", calculator_type: nil } }
  end
end
