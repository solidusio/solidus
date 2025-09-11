# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Asset, type: :model do
  describe "#viewable" do
    it "touches association" do
      product = create(:custom_product)

      expect do
        Spree::Asset.create! { |a| a.viewable = product.master }
      end.to change { product.updated_at }
    end
  end

  describe "#acts_as_list scope" do
    it "should start from first position for different viewables" do
      asset1 = Spree::Asset.create(viewable_type: "Spree::Image", viewable_id: 1)
      asset2 = Spree::Asset.create(viewable_type: "Spree::LineItem", viewable_id: 1)

      expect(asset1.position).to eq 1
      expect(asset2.position).to eq 1
    end
  end
end
