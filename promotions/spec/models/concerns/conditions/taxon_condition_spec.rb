# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Conditions::TaxonCondition do
  let(:condition_class) do
    Class.new(SolidusPromotions::Condition) do
      include SolidusPromotions::Conditions::TaxonCondition

      def self.name
        "SomeCondition"
      end
    end
  end

  subject(:condition) { condition_class.new }

  it_behaves_like "a taxon condition"
end
