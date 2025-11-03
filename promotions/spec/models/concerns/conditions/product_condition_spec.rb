# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Conditions::ProductCondition do
  let(:condition_class) do
    Class.new(SolidusPromotions::Condition) do
      include SolidusPromotions::Conditions::ProductCondition

      def self.name
        "SomeCondition"
      end
    end
  end

  subject(:condition) { condition_class.new }

  it { is_expected.to have_many :products }

  describe "#product_ids_string" do
    it "returns a string of product ids" do
      condition.products = [create(:product), create(:product)]
      expect(condition.product_ids_string).to eq("#{condition.products[0].id},#{condition.products[1].id}")
    end
  end

  describe "#preload_relations" do
    subject { condition.preload_relations }
    it { is_expected.to eq([:products]) }
  end

  describe "#product_ids_string=" do
    it "sets products based on a string of product ids" do
      product_one = create(:product)
      product_two = create(:product)
      condition.product_ids_string = "#{product_one.id},#{product_two.id}"
      expect(condition.products).to eq([product_one, product_two])
    end
  end

  describe "#preload_relations" do
    subject { condition.preload_relations }
    it { is_expected.to eq([:products]) }
  end
end
