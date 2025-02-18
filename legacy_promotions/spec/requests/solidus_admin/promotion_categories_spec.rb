# frozen_string_literal: true

require 'rails_helper'
require 'solidus_admin/testing_support/shared_examples/promotion_categories_requests'

RSpec.describe 'SolidusAdmin::PromotionCategoriesController', :solidus_admin, type: :request do
  include_examples 'promotion categories requests' do
    let(:factory_name) { :promotion_category }
    let(:url_helpers) { solidus_admin }
    let(:model_class) { Spree::PromotionCategory }
  end
end
