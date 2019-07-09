# frozen_string_literal: true

require 'spree/backend/tabs/product/base'

module Spree
  module Backend
    module Tabs
      class Product
        class ProductProperties < Base
          def name
            'Product Properties'
          end

          def presentation
            view_context.plural_resource_name(Spree::ProductProperty)
          end

          def url
            view_context.spree.admin_product_product_properties_url(product)
          end

          def visible?
            view_context.can?(:admin, Spree::ProductProperty) && !product.deleted?
          end
        end
      end
    end
  end
end
