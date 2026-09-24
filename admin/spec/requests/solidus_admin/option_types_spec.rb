# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/crud_resource_requests"
require "solidus_admin/testing_support/shared_examples/moveable"

RSpec.describe "SolidusAdmin::OptionTypesController", type: :request do
  it_behaves_like "CRUD resource requests", "option_type" do
    let(:resource_class) { Spree::OptionType }
    let(:valid_attributes) { {name: "color", presentation: "Color"} }
    let(:invalid_attributes) { {name: ""} }
    let(:expected_after_create_path) { %r{/admin/option_types/\d+/edit} }
  end

  it_behaves_like "requests: moveable" do
    let(:factory) { :option_type }
  end

  describe "GET /index" do
    let(:admin_user) { create(:admin_user) }

    before do
      allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
    end

    it "gives the sortable controller the page number and page size" do
      create_list(:option_type, 21)

      get solidus_admin.option_types_path(page: 2)

      expect(response.body).to include("data-sortable-page-value=2")
      expect(response.body).to include("data-sortable-per-page-value=20")
    end
  end
end
