# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solidus::Asset, type: :model do
  describe "#viewable" do
    it "touches association" do
      product = build(:custom_product)

      expect do
        Solidus::Asset.create! { |a| a.viewable = product.master }
      end.to change { product.updated_at }
    end
  end

  describe "#acts_as_list scope" do
    it "should start from first position for different viewables" do
      asset1 = Solidus::Asset.create(viewable_type: 'Solidus::Image', viewable_id: 1)
      asset2 = Solidus::Asset.create(viewable_type: 'Solidus::LineItem', viewable_id: 1)

      expect(asset1.position).to eq 1
      expect(asset2.position).to eq 1
    end
  end
end
