# frozen_string_literal: true

module Spree
  module Api
    class ImagesController < Spree::Api::BaseController
      def index
        @images = scope.images.accessible_by(current_ability, :read)
        respond_with(@images)
      end

      def show
        @image = scope.images.accessible_by(current_ability, :read).find(params[:id])
        respond_with(@image)
      end

      def create
        authorize! :create, Image

        @image = scope.images.build(image_params.except(:attachment))
        @image.attachment = prepared_attachment
        @image.save

        respond_with(@image, status: 201, default_template: :show)
      end

      def update
        @image = scope.images.accessible_by(current_ability, :update).find(params[:id])
        if image_params[:attachment].present?
          @image.assign_attributes(image_params.except(:attachment))
          @image.attachment = prepared_attachment
          @image.save
        else
          @image.update image_params
        end
        respond_with(@image, default_template: :show)
      end

      def destroy
        @image = scope.images.accessible_by(current_ability, :destroy).find(params[:id])
        @image.destroy
        respond_with(@image, status: 204)
      end

      private

      def image_params
        params.require(:image).permit(permitted_image_attributes)
      end

      def scope
        if params[:product_id]
          Spree::Product.friendly.find(params[:product_id])
        elsif params[:variant_id]
          Spree::Variant.find(params[:variant_id])
        end
      end

      def prepared_attachment
        uri = URI.parse image_params[:attachment]
        if uri.is_a? URI::HTTP
          require 'private_address_check'
          if PrivateAddressCheck.resolves_to_private_address? uri.host
            raise PrivateAddressCheck::PrivateConnectionAttemptedError
          else
            URI.open(image_params[:attachment], redirect: false)
          end
        else
          image_params[:attachment]
        end
      rescue URI::InvalidURIError
        image_params[:attachment]
      end
    end
  end
end
