# frozen_string_literal: true

require "spec_helper"
require 'solidus_admin/testing_support/shared_examples/crud_resource_requests'

RSpec.describe "SolidusAdmin::AdjustmentReasonsController", type: :request do
  include_examples 'CRUD resource requests', 'adjustment_reason' do
    let(:resource_class) { Spree::AdjustmentReason }
    let(:valid_attributes) { { name: "Price Adjustment", code: "PRICE_ADJUST", active: true } }
    let(:invalid_attributes) { { name: "", code: "", active: true } }
  end
end
