# frozen_string_literal: true

require 'spree/backend/tabs/product/base'

module Spree
  module Backend
    module Tabs
      class Product
        class Variants < Base
          def name
            'Variants'
          end

          def presentation
            view_context.plural_resource_name(Spree::Variant)
          end

          def url
            view_context.spree.admin_product_variants_url(product)
          end

          def visible?
            view_context.can?(:admin, Spree::Variant)
          end
        end
      end
    end
  end
end
