# frozen_string_literal: true

module Spree
  module Admin
    class ImagesController < ResourceController
      before_action :load_data

      create.before :set_viewable
      create.after :update_variant_image

      private

      def location_after_destroy
        admin_product_images_url(@product)
      end

      def location_after_save
        admin_product_images_url(@product)
      end

      def load_data
        @product = Spree::Product.friendly.find(params[:product_id])
        @variants = @product.variants.collect do |variant|
          [variant.sku_and_options_text, variant.id]
        end
        @variants.insert(0, [t('spree.all'), @product.master.id])
      end

      def set_viewable
        variant = @product.variants_including_master.find(params[:image][:viewable_id])
        @variant_image = variant.images_variants.create
        @image.viewable_type = 'Spree::ImagesVariant'
        @image.viewable_id = @variant_image.id
      end

      def update_variant_image
        @variant_image.image = @image
        @variant_image.save
      end
    end
  end
end
