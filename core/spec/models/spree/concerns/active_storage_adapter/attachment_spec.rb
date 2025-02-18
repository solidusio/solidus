# frozen_string_literal: true

require "rails_helper"

unless ENV["DISABLE_ACTIVE_STORAGE"] == "true"
  RSpec.describe Spree::ActiveStorageAdapter::Attachment do
    describe "#variant" do
      it "converts to resize_to_limit when definition doesn't contain any special symbol" do
        image = create(:image)

        attachment = described_class.new(image.attachment.attachment, styles: {mini: "10x10"})

        expect(
          attachment.variant(:mini).variation.transformations
        ).to include(resize_to_limit: [10, 10])
      end

      it "converts to resize_to_limit when definition ends with >" do
        image = create(:image)

        attachment = described_class.new(image.attachment.attachment, styles: {mini: "10x10>"})

        expect(
          attachment.variant(:mini).variation.transformations
        ).to include(resize_to_limit: [10, 10])
      end

      it "converts to resize_to_fill when definition ends with ^" do
        image = create(:image)

        attachment = described_class.new(image.attachment.attachment, styles: {mini: "10x10^"})

        expect(
          attachment.variant(:mini).variation.transformations
        ).to include(resize_to_fill: [10, 10])
      end

      it "strips definitions" do
        image = create(:image)

        attachment = described_class.new(image.attachment.attachment, styles: {mini: " 10x10 "})

        expect(
          attachment.variant(:mini).variation.transformations
        ).to include(resize_to_limit: [10, 10])
      end

      it "defaults to the image's width and height" do
        image = create(:image)

        attachment = described_class.new(image.attachment.attachment, styles: {})

        expect(
          attachment.variant(:mini).variation.transformations
        ).to include(resize_to_limit: [attachment.width, attachment.height])
      end
    end
  end
end
