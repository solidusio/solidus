# frozen_string_literal: true

require 'spree/backend/tabs/product/base'

module Spree
  module Backend
    module Tabs
      class Product
        class StockManagement < Base
          def name
            'Stock Management'
          end

          def presentation
            view_context.t('spree.stock_management')
          end

          def url
            view_context.spree.admin_product_stock_url(product)
          end

          def visible?
            view_context.can?(:admin, Spree::StockItem) && !product.deleted?
          end
        end
      end
    end
  end
end
