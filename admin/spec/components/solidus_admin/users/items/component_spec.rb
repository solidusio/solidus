# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Users::Items::Component, type: :component do
  describe "description column" do
    it "escapes the product name, variant options and SKU", :aggregate_failures do
      product = Spree::Product.new(name: %(<img id="name">Shirt))
      option_type = Spree::OptionType.new(presentation: %(<i id="option-type">Size</i>), position: 1)
      option_value = Spree::OptionValue.new(option_type: option_type, presentation: %(<b id="option-value">Small</b>))
      variant = Spree::Variant.new(product: product, sku: %(<u id="sku">SKU-1</u>), option_values: [option_value])
      order = Spree::Order.new(created_at: Time.current, number: "R123", state: "complete", currency: "USD")
      item = Spree::LineItem.new(order: order, variant: variant, quantity: 1, price: 10)
      allow(item).to receive(:product).and_return(product)
      user = Spree.user_class.new(id: 1, created_at: Time.current)

      render_inline described_class.new(user: user, items: [item])

      expect(page).not_to have_css("#name", visible: :all)
      expect(page).not_to have_css("#option-type", visible: :all)
      expect(page).not_to have_css("#option-value", visible: :all)
      expect(page).not_to have_css("#sku", visible: :all)

      expect(page).to have_text(%(<img id="name">Shirt))
      expect(page).to have_text(%((<i id="option-type">Size</i>: <b id="option-value">Small</b>)))
      expect(page).to have_text(%(<u id="sku">SKU-1</u>))
      expect(page).to have_css("strong", text: "SKU:")
    end
  end
end
