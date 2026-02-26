# frozen_string_literal: true

require "rails_helper"
require "solidus_admin/testing_support/shared_examples/crud_resource_requests"

RSpec.describe "SolidusPromotions::PromotionCategoriesController", :solidus_admin, type: :request do
  include_examples "CRUD resource requests", "promotion_category" do
    let(:resource_class) { SolidusPromotions::PromotionCategory }
    let(:valid_attributes) { {name: "Expired", code: "exp.1"} }
    let(:invalid_attributes) { {name: "", code: ""} }
    let(:factory) { :solidus_promotion_category }
    let(:url_helpers) { solidus_promotions }
  end
end
