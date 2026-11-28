# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/crud_resource_requests"

RSpec.describe "SolidusAdmin::ReimbursementTypesController", type: :request do
  include_examples "CRUD resource requests", "reimbursement_type" do
    let(:resource_class) { Spree::ReimbursementType }
    let(:valid_attributes) { {name: "Store Credit Refund", active: true} }
    let(:invalid_attributes) { {name: "", active: true} }
  end
end
