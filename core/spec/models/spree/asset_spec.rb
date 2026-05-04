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

  describe ".attachment_preloads" do
    context "when the class uses ActiveStorage" do
      let(:asset_class) do
        Class.new(Spree::Asset) do
          include Spree::Image::ActiveStorageAttachment
        end
      end

      it "returns the nested attachment + blob + variant preloads" do
        expect(asset_class.attachment_preloads).to eq(
          [{attachment_attachment: {blob: {variant_records: {image_attachment: :blob}}}}]
        )
      end
    end

    context "when the class uses Paperclip" do
      let(:asset_class) do
        Class.new(Spree::Asset) do
          include Spree::Image::PaperclipAttachment
        end
      end

      it "returns an empty array (no-op nested preload)" do
        expect(asset_class.attachment_preloads).to eq([])
      end
    end

    context "when called on Spree::Asset itself" do
      it "returns an empty array since no attachment is configured" do
        expect(Spree::Asset.attachment_preloads).to eq([])
      end
    end
  end
end
