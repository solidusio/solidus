# frozen_string_literal: true

require "spec_helper"
require 'solidus_admin/testing_support/shared_examples/crud_resource_requests'

RSpec.describe "SolidusAdmin::OptionValuesController", type: :request do
  include_examples "CRUD resource requests", "option_value", except: %i[index] do
    let(:resource_class) { Spree::OptionValue }
    # let(:resource) { create(:option_value, option_type: create(:option_type)) }
    let(:valid_attributes) { { name: "yellow", presentation: "Yellow" } }
    let(:invalid_attributes) { { name: "" } }

    let(:resources_path) { solidus_admin.option_type_option_values_path(resource.option_type) }
    let(:new_resource_path) { solidus_admin.new_option_type_option_value_path(resource.option_type) }
    let(:edit_resource_path) { solidus_admin.edit_option_value_path(resource) }
    let(:resource_path) { solidus_admin.option_value_path(resource) }

    let(:expected_after_create_path) { %r(/admin/option_types/\d+/edit) }
    let(:expected_after_update_path) { %r(/admin/option_types/\d+/edit) }
    let(:expected_after_destroy_path) { %r(/admin/option_types/\d+/edit) }
  end
end
