# frozen_string_literal: true

class ProductCardComponent < ViewComponent::Base
  def initialize(
    product,
    locale: I18n.locale,
    price: product.master.default_price,
    additional_classes: '',
    home_collection: false
  )
    @product = product
    @locale = locale
    @price = price
    @additional_classes = additional_classes
    @home_collection = home_collection
  end

  attr_reader :product, :locale, :price, :additional_classes

  def main_image
    product.gallery.images.first
  end

  def display_price
    @display_price ||= price&.money
  end
end
