# frozen_string_literal: true

require "spec_helper"
require 'solidus_admin/testing_support/shared_examples/crud_resource_requests'

RSpec.describe "SolidusAdmin::OptionValuesController", type: :request do
  include_examples "CRUD resource requests", "option_value", except: %i[index] do
    let(:resource_class) { Spree::OptionValue }
    let(:valid_attributes) { { name: "yellow", presentation: "Yellow" } }
    let(:invalid_attributes) { { name: "" } }
    let(:expected_after_create_path) { %r(/admin/option_types/\d+/edit) }
    let(:expected_after_update_path) { %r(/admin/option_types/\d+/edit) }
    let(:expected_after_destroy_path) { %r(/admin/option_types/\d+/edit) }
  end
end
