# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/crud_resource_requests"

RSpec.describe "SolidusAdmin::ReturnReasonsController", type: :request do
  include_examples "CRUD resource requests", "return_reason" do
    let(:resource_class) { Spree::ReturnReason }
    let(:valid_attributes) { {name: "Valid Return Reason", active: false} }
    let(:invalid_attributes) { {name: "", active: false} }
  end
end
