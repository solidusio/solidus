# frozen_string_literal: true

require 'rails_helper'
require 'solidus_admin/testing_support/shared_examples/crud_resource_requests'

RSpec.describe 'SolidusAdmin::PromotionCategoriesController', :solidus_admin, type: :request do
  include_examples 'CRUD resource requests', 'promotion_category' do
    let(:resource_class) { Spree::PromotionCategory }
    let(:valid_attributes) { { name: "Expired", code: "exp.1" } }
    let(:invalid_attributes) { { name: "", code: "" } }
  end
end
