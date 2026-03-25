# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/crud_resource_requests"

RSpec.describe "SolidusAdmin::RolesController", type: :request do
  include_examples "CRUD resource requests", "role" do
    let(:resource_class) { Spree::Role }
    let(:valid_attributes) { {name: "Customer", description: "A person who buys stuff"} }
    let(:invalid_attributes) { {name: ""} }
  end
end
