# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Taxonomy, type: :model do
  context "validations" do
    subject { build(:taxonomy, name: "Brand") }

    let!(:taxonomy) { create(:taxonomy, name: "Brand") }

    context "name validations" do
      it "ensures Taxonomies must have unique names" do
        expect(subject.save).to eq(false)
        expect(subject.errors.full_messages).to match_array(["Name has already been taken"])
      end
    end
  end

  context "#destroy" do
    subject(:association_options) do
      described_class.reflect_on_association(:root).options
    end

    it "should destroy all associated taxons" do
      expect(association_options[:dependent]).to eq :destroy
    end
  end
end
