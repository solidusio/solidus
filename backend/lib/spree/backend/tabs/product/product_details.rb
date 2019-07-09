# frozen_string_literal: true

require 'spree/backend/tabs/product/base'

module Spree
  module Backend
    module Tabs
      class Product
        class ProductDetails < Base
          def name
            'Product Details'
          end

          def presentation
            view_context.t('spree.product_details')
          end

          def url
            view_context.spree.edit_admin_product_url(product)
          end

          def visible?
            view_context.can?(:admin, Spree::Product)
          end
        end
      end
    end
  end
end
