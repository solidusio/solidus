# frozen_string_literal: true

class SolidusAdmin::Products::Index::Component < SolidusAdmin::BaseComponent
  def initialize(products:)
    @products = products
  end

  # @!visibility private

  def image_column(product)
    link_to(
      image_tag(product.gallery.images.first.url(:small), class: 'h-[40px] w-[40px] max-w-[40px]'),
      spree.edit_admin_product_path(product),
    )
  end

  def name_column(product)
    link_to product.name, spree.edit_admin_product_path(product)
  end

  def price_column(product)
    product.master.display_price.to_html
  end
end
