# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/moveable"

RSpec.describe "SolidusAdmin::PaymentMethodsController", type: :request do
  it_behaves_like "requests: moveable" do
    let(:factory) { :payment_method }
    let(:request_path) { solidus_admin.move_payment_method_path(record, format: :js) }
  end
end
