# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Conditions::OptionValueCondition do
  let(:condition_class) do
    Class.new(SolidusPromotions::Condition) do
      include SolidusPromotions::Conditions::OptionValueCondition

      def self.name
        "SomeCondition"
      end
    end
  end

  subject(:condition) { condition_class.new }

  describe "#preferred_eligible_values" do
    subject { condition.preferred_eligible_values }

    it "assigns a nicely formatted hash" do
      condition.preferred_eligible_values = { "5" => "1,2", "6" => "1" }
      expect(subject).to eq({ 5 => [1, 2], 6 => [1] })
    end
  end
end
