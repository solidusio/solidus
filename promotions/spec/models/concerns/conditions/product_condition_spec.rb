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

  it_behaves_like "a product condition"
end
