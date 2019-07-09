# frozen_string_literal: true

module Spree
  module Backend
    module Tabs
      class Product
        attr_reader :view_context, :current, :items

        def initialize(view_context:, current: nil)
          @view_context = view_context
          @current = current
          @items = Config.product_tabs.items
        end

        def each
          items.each do |item|
            yield item.new(view_context: view_context, current: current)
          end
        end
      end
    end
  end
end

require 'spree/backend/tabs/product/images'
require 'spree/backend/tabs/product/prices'
require 'spree/backend/tabs/product/product_details'
require 'spree/backend/tabs/product/product_properties'
require 'spree/backend/tabs/product/stock_management'
require 'spree/backend/tabs/product/variants'
