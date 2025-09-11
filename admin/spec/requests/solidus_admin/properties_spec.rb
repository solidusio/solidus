# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/crud_resource_requests"

RSpec.describe "SolidusAdmin::PropertiesController", type: :request do
  include_examples "CRUD resource requests", "property" do
    let(:resource_class) { Spree::Property }
    let(:valid_attributes) { {name: "Material", presentation: "Material Type"} }
    let(:invalid_attributes) { {name: "", presentation: ""} }
  end
end
