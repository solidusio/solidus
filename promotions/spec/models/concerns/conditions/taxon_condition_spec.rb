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

  it { is_expected.to have_many :taxons }

  describe "#taxon_ids_string" do
    it "returns a string of taxon ids" do
      condition.taxons = [create(:taxon), create(:taxon)]
      expect(condition.taxon_ids_string).to eq("#{condition.taxons[0].id},#{condition.taxons[1].id}")
    end
  end

  describe "#preload_relations" do
    subject { condition.preload_relations }
    it { is_expected.to eq([:taxons]) }
  end

  describe "#taxon_ids_string=" do
    it "sets taxons based on a string of taxon ids" do
      taxon_one = create(:taxon)
      taxon_two = create(:taxon)
      condition.taxon_ids_string = "#{taxon_one.id},#{taxon_two.id}"
      expect(condition.taxons).to eq([taxon_one, taxon_two])
    end
  end

  describe "#preload_relations" do
    subject { condition.preload_relations }
    it { is_expected.to eq([:taxons]) }
  end
end
