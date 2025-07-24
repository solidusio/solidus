# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/moveable"
require 'solidus_admin/testing_support/shared_examples/crud_resource_requests'

RSpec.describe "SolidusAdmin::PaymentMethodsController", type: :request do
  it_behaves_like "requests: moveable" do
    let(:factory) { :payment_method }
    let(:request_path) { solidus_admin.move_payment_method_path(record, format: :js) }
  end

  include_examples "CRUD resource requests", "payment_method" do
    let(:resource_class) { Spree::PaymentMethod }
    let(:valid_attributes) { { name: "Credit Card", type: "Spree::PaymentMethod::BogusCreditCard" } }
    let(:invalid_attributes) { { name: "", type: "" } }
  end
end
