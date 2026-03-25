# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Image, type: :model do
  custom_styles = {
    mini: "48x48>",
    small: "100x100>",
    product: "240x240>",
    large: "600x600>",
    jumbo: "1200x1200>"
  }
  custom_style_default = :other

  it "correctly sets the image styles ActiveStorage" do
    stub_spree_preferences(
      product_image_styles: custom_styles,
      product_image_style_default: custom_style_default
    )

    # We make use of a custom class, such that the preferences loaded
    # are the mocked ones.
    active_storage_asset = Class.new(Spree::Asset) do
      include Spree::Image::ActiveStorageAttachment
    end

    expect(active_storage_asset.attachment_definitions[:attachment][:styles]).to eq(custom_styles)
    expect(active_storage_asset.attachment_definitions[:attachment][:default_style]).to eq(custom_style_default)
  end

  it "correctly sets the image styles Paperclip" do
    stub_spree_preferences(
      product_image_styles: custom_styles,
      product_image_style_default: custom_style_default
    )

    # We make use of a custom class, such that the preferences loaded
    # are the mocked ones.
    paperclip_asset = Class.new(Spree::Asset) do
      include Spree::Image::PaperclipAttachment
    end

    expect(paperclip_asset.attachment_definitions[:attachment][:styles]).to eq(custom_styles)
    expect(paperclip_asset.attachment_definitions[:attachment][:default_style]).to eq(custom_style_default)
  end
end
