# frozen_string_literal: true

require "rails_helper"
require "solidus_admin/testing_support/shared_examples/promotion_categories_features"

RSpec.describe "Promotion Categories", :js, type: :feature, solidus_admin: true do
  include_examples "promotion categories features" do
    let(:factory_name) { :solidus_promotion_category }
    let(:model_class) { SolidusPromotions::PromotionCategory }
    let(:index_path) { "/admin/solidus/promotion_categories" }
  end
end
