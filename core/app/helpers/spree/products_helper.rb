module Spree
  module ProductsHelper
    # Returns the formatted price for the specified variant as a full price or
    # a difference depending on configuration
    #
    # @param variant [Spree::Variant] the variant
    # @return [Spree::Money] the price or price diff
    def variant_price(variant)
      if Spree::Config[:show_variant_full_price]
        variant_full_price(variant)
      else
        variant_price_diff(variant)
      end
    end

    # Returns the formatted price for the specified variant as a difference
    # from product price
    #
    # @param variant [Spree::Variant] the variant
    # @return [String] formatted string with label and amount
    def variant_price_diff(variant)
      variant_amount = variant.amount_in(current_currency)
      product_amount = variant.product.amount_in(current_currency)
      return if variant_amount == product_amount || product_amount.nil?
      diff   = variant.amount_in(current_currency) - product_amount
      amount = Spree::Money.new(diff.abs, currency: current_currency).to_html
      label  = diff > 0 ? :add : :subtract
      "(#{Spree.t(label)}: #{amount})".html_safe
    end

    # Returns the formatted full price for the variant, if at least one variant
    # price differs from product price.
    #
    # @param variant [Spree::Variant] the variant
    # @return [Spree::Money] the full price
    def variant_full_price(variant)
      product = variant.product
      unless product.variants.active(current_currency).all? { |v| v.price == product.price }
        Spree::Money.new(variant.price, { currency: current_currency }).to_html
      end
    end

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

    # Deprecated and may be removed from future releases; use
    # line_item_description_text(line_item.description) instead.
    def line_item_description(variant)
      ActiveSupport::Deprecation.warn "line_item_description(variant) is deprecated and may be removed from future releases, use line_item_description_text(line_item.description) instead.", caller

      line_item_description_text(variant.product.description)
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
  end
end
