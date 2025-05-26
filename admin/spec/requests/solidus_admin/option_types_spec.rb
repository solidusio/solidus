# frozen_string_literal: true

require "spec_helper"
require 'solidus_admin/testing_support/shared_examples/crud_resource_requests'

RSpec.describe "SolidusAdmin::OptionTypesController", type: :request do
  include_examples "CRUD resource requests", "option_type" do
    let(:resource_class) { Spree::OptionType }
    let(:valid_attributes) { { name: "color", presentation: "Color" } }
    let(:invalid_attributes) { { name: "" } }
    let(:expected_after_create_path) { %r(/admin/option_types/\d+/edit) }
  end
end
