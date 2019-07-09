# frozen_string_literal: true

require 'spree/backend/tabs/product/base'

module Spree
  module Backend
    module Tabs
      class Product
        class Images < Base
          def name
            'Images'
          end

          def presentation
            view_context.t('spree.images')
          end

          def url
            view_context.spree.admin_product_images_url(product)
          end

          def visible?
            view_context.can?(:admin, Spree::Image) && !product.deleted?
          end
        end
      end
    end
  end
end
