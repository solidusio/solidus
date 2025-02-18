# frozen_string_literal: true

require "spec_helper"
require 'solidus_admin/testing_support/shared_examples/crud_resource_requests'

RSpec.describe "SolidusAdmin::RefundReasonsController", type: :request do
  include_examples 'CRUD resource requests', 'refund_reason' do
    let(:resource_class) { Spree::RefundReason }
    let(:valid_attributes) { { name: "Refund for Defective Item", code: "DEFECT", active: true } }
    let(:invalid_attributes) { { name: "", code: "", active: true } }
  end
end
