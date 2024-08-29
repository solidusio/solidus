# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/crud_resource_requests"

RSpec.describe "SolidusAdmin::StoreCreditReasonsController", type: :request do
  include_examples "CRUD resource requests", "store_credit_reason" do
    let(:resource_class) { Spree::StoreCreditReason }
    let(:valid_attributes) { {name: "Customer Loyalty", active: true} }
    let(:invalid_attributes) { {name: "", active: true} }
  end
end
