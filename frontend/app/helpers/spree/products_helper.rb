require 'truncate_html'
require 'app/helpers/truncate_html_helper'

module Spree
  module ProductsHelper
    include TruncateHtmlHelper

    # Converts line breaks in product description into <p> tags.
    #
    # @param product [Spree::Product] the product whose description you want to filter
    # @return [String] the generated HTML
    def product_description(product)
      if Spree::Config[:show_raw_product_description]
        raw(product.description)
      else
        raw(product.description.gsub(/(.*?)\r?\n\r?\n/m, '<p>\1</p>'))
      end
    end

    # Filters and truncates the given description.
    #
    # @param description_text [String] the text to filter
    # @return [String] the filtered text
    def line_item_description_text(description_text)
      if description_text.present?
        truncate(strip_tags(description_text.gsub('&nbsp;', ' ')), length: 100)
      else
        Spree.t(:product_has_no_description)
      end
    end

    # @return [String] a cache invalidation key for products
    def cache_key_for_products
      count = @products.count
      max_updated_at = (@products.maximum(:updated_at) || Date.today).to_s(:number)
      "#{I18n.locale}/#{current_currency}/spree/products/all-#{params[:page]}-#{max_updated_at}-#{count}"
    end

    def truncated_product_description(product)
      truncate_html(raw(product.description))
    end
  end
end
