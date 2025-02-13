# frozen_string_literal: true

require 'rails_helper'
require 'solidus_admin/testing_support/shared_examples/promotion_categories_requests'

RSpec.describe 'SolidusPromotions::PromotionCategoriesController', :solidus_admin, type: :request do
  include_examples 'promotion categories requests' do
    let(:promotion_category) { create(:solidus_promotion_category) }
    let(:url_helpers) { solidus_promotions }
    let(:model_class) { SolidusPromotions::PromotionCategory }
  end
end
