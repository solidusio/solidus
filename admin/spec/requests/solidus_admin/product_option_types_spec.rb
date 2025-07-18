# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/moveable"

RSpec.describe "SolidusAdmin::ProductOptionTypesController", type: :request do
  it_behaves_like "requests: moveable" do
    let(:factory) { :product_option_type }
    let(:request_path) { solidus_admin.move_product_option_type_path(record, format: :js) }
  end
end
