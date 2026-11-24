# frozen_string_literal: true

module SolidusAdmin
  class ProductImagesController < SolidusAdmin::BaseController
    before_action :load_product, only: [:new, :create, :destroy]

    def new
      @image = @product.master.images.new
      render component("products/show/images/new").new(product: @product, image: @image)
    end

    def create
      attachments = (image_params[:attachment] || []).reject(&:blank?)

      if attachments.any?
        @images = attachments.map { @product.master.images.new(attachment: _1) }

        if @images.all?(&:save)
          respond_to do |format|
            format.html { redirect_to @product, status: :see_other }
            format.turbo_stream
          end
        else
          @image = @images.first
          render component("products/show").new(product: @product), status: :unprocessable_entity
        end
      else
        @image = @product.master.images.new
        render component("products/show").new(product: @product), status: :unprocessable_entity
      end
    end

    def destroy
      images = Spree::Image.where(id: Array.wrap(params[:id]))
      count = images.size
      images.destroy_all

      flash[:notice] = t("solidus_admin.products.images.destroy.success", count:)

      redirect_to @product, status: :see_other
    end

    private

    def load_product
      @product = Spree::Product.friendly.find(params[:product_id])
    end

    def image_params
      params.require(:image).permit(:alt, :position, attachment: [])
    end

    def authorization_subject
      Spree::Image
    end
  end
end
