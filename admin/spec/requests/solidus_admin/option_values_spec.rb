# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/crud_resource_requests"
require "solidus_admin/testing_support/shared_examples/moveable"

RSpec.describe "SolidusAdmin::OptionValuesController", type: :request do
  include_examples "CRUD resource requests", "option_value", except: %i[index destroy_single] do
    let(:resource_class) { Spree::OptionValue }
    let(:valid_attributes) { { name: "yellow", presentation: "Yellow" } }
    let(:invalid_attributes) { { name: "" } }

    let!(:resources_path) { solidus_admin.option_type_option_values_path(resource.option_type, format:) }
    let!(:new_resource_path) { solidus_admin.new_option_type_option_value_path(resource.option_type) }
    let!(:edit_resource_path) { solidus_admin.edit_option_value_path(resource) }
    let!(:resource_path) { solidus_admin.option_value_path(resource, format:) }

    let(:format) { :html }

    let(:expected_after_create_path) { %r(/admin/option_types/\d+/edit) }
    let(:expected_after_update_path) { %r(/admin/option_types/\d+/edit) }
    let(:expected_after_destroy_path) { %r(/admin/option_types/\d+/edit) }

    context "when format is turbo_stream" do
      let(:format) { :turbo_stream }

      shared_examples_for "responds with turbo stream" do
        it "responds with turbo stream" do
          expect(response.content_type).to include("text/vnd.turbo-stream.html")
          expect(response).to have_http_status(:ok)
        end
      end

      context "#create" do
        include_examples "responds with turbo stream" do
          before { post resources_path, params: { option_value: valid_attributes } }
        end
      end

      context "#update" do
        include_examples "responds with turbo stream" do
          before { patch resource_path, params: { option_value: valid_attributes } }
        end
      end

      context "#destroy" do
        include_examples "responds with turbo stream" do
          before { delete resources_path, params: { ids: [resource.id] } }
        end
      end
    end
  end

  include_examples "requests: moveable" do
    let(:factory) { :option_value }
  end
end
