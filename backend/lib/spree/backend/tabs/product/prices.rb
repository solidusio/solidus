# frozen_string_literal: true

require 'spree/backend/tabs/product/base'

module Spree
  module Backend
    module Tabs
      class Product
        class Prices < Base
          def name
            'Prices'
          end

          def presentation
            view_context.plural_resource_name(Spree::Price)
          end

          def url
            view_context.spree.admin_product_prices_url(product)
          end

          def visible?
            view_context.can?(:admin, Spree::Price) && !product.deleted?
          end
        end
      end
    end
  end
end
