# frozen_string_literal: true

require "spec_helper"
require 'solidus_admin/testing_support/shared_examples/crud_resource_requests'

RSpec.describe "SolidusAdmin::StoresController", type: :request do
  before { create(:store, default: true) } # create a default store so that we operate on a non-default one

  include_examples 'CRUD resource requests', 'store' do
    let(:resource_class) { Spree::Store }
    let(:valid_attributes) { { name: "Store", code: "store", url: "store.com", mail_from_address: "store@example.com" } }
    let(:invalid_attributes) { { name: "" } }
  end
end
